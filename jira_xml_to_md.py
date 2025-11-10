#!/usr/bin/env python3
"""
JIRA XML to Markdown Converter
Converts JIRA XML exports to structured Markdown files for agent context.
"""


import xml.etree.ElementTree as ET
import re
from pathlib import Path
from datetime import datetime
from html import unescape



def clean_html(html_text):
    """Convert HTML to clean Markdown-friendly text."""
    if not html_text:
        return ""
    
    # Unescape HTML entities
    text = unescape(html_text)
    
    # Track nesting level for lists
    indent_level = 0
    
    # Convert ordered lists with proper numbering
    def convert_ol(match):
        nonlocal indent_level
        content = match.group(1)
        indent_level += 1
        # Process list items within this ol
        items = re.findall(r'<li>(.*?)</li>', content, re.DOTALL)
        result = []
        for i, item in enumerate(items, 1):
            indent = '  ' * (indent_level - 1)
            # Replace internal newlines with spaces to keep each item on one line
            item_text = re.sub(r'\s+', ' ', item.strip())
            result.append(f'{indent}{i}. {item_text}')
        indent_level -= 1
        return '\n\n' + '\n'.join(result) + '\n\n'
    
    # Convert unordered lists
    def convert_ul(match):
        nonlocal indent_level
        content = match.group(1)
        indent_level += 1
        # Process list items within this ul
        items = re.findall(r'<li>(.*?)</li>', content, re.DOTALL)
        result = []
        for item in items:
            indent = '  ' * (indent_level - 1)
            # Replace internal newlines with spaces to keep each item on one line
            item_text = re.sub(r'\s+', ' ', item.strip())
            result.append(f'{indent}- {item_text}')
        indent_level -= 1
        return '\n\n' + '\n'.join(result) + '\n\n'
    
    # Process nested lists from innermost to outermost
    max_iterations = 20
    iteration = 0
    while ('<ol>' in text or '<ul>' in text) and iteration < max_iterations:
        # Find and replace innermost lists first
        text = re.sub(r'<ol>((?:(?!<ol>).)*?)</ol>', convert_ol, text, flags=re.DOTALL)
        text = re.sub(r'<ul>((?:(?!<ul>).)*?)</ul>', convert_ul, text, flags=re.DOTALL)
        iteration += 1
    
    # Convert common HTML tags to Markdown
    text = re.sub(r'<b>(.*?)</b>', r'**\1**', text, flags=re.DOTALL)
    text = re.sub(r'<strong>(.*?)</strong>', r'**\1**', text, flags=re.DOTALL)
    text = re.sub(r'<i>(.*?)</i>', r'*\1*', text, flags=re.DOTALL)
    text = re.sub(r'<em>(.*?)</em>', r'*\1*', text, flags=re.DOTALL)
    text = re.sub(r'<code>(.*?)</code>', r'`\1`', text, flags=re.DOTALL)
    
    # Convert paragraphs
    text = re.sub(r'<p>(.*?)</p>', r'\1\n\n', text, flags=re.DOTALL)
    
    # Convert line breaks
    text = re.sub(r'<br\s*/?>', '\n', text)
    
    # Remove remaining HTML tags (like font, span, etc.)
    text = re.sub(r'<[^>]+>', '', text)
    
    # Clean up extra whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'[ \t]+\n', '\n', text)  # Remove trailing spaces
    text = text.strip()
    
    return text



def get_element_html(element):
    """Extract HTML content from an element preserving tags."""
    if element is None:
        return ''
    # Get the inner XML/HTML content
    text = ET.tostring(element, encoding='unicode', method='html')
    # Remove the outer element tags
    text = re.sub(r'^<[^>]+>', '', text)
    text = re.sub(r'</[^>]+>$', '', text)
    return text



def parse_jira_xml(xml_content):
    """Parse JIRA XML and extract story information."""
    # Clean up duplicate attributes that JIRA sometimes exports
    xml_content = re.sub(r'rel="[^"]*"\s+data-account-id="[^"]*"\s+accountid="[^"]*"\s+rel="[^"]*"', 
                         lambda m: m.group(0).replace(' rel="noreferrer"', '', 1), xml_content)
    
    root = ET.fromstring(xml_content)
    
    # Navigate to the item element
    item = root.find('.//item')
    if item is None:
        raise ValueError("No item found in XML")
    
    # Extract basic fields
    desc_elem = item.find('description')
    story = {
        'key': item.findtext('key', ''),
        'title': item.findtext('summary', ''),
        'description': clean_html(get_element_html(desc_elem)),
        'status': item.findtext('status', ''),
        'priority': item.findtext('priority', ''),
        'assignee': item.findtext('assignee', 'Unassigned'),
        'reporter': item.findtext('reporter', ''),
        'created': item.findtext('created', ''),
        'updated': item.findtext('updated', ''),
        'type': item.findtext('type', ''),
        'link': item.findtext('link', ''),
        'labels': [],
        'time_estimate': item.findtext('timeestimate', ''),
        'time_spent': item.findtext('timespent', ''),
        'comments': [],
        'custom_fields': {}
    }
    
    # Extract labels
    labels = item.findall('.//label')
    story['labels'] = [label.text for label in labels if label.text]
    
    # Extract comments
    comments = item.findall('.//comment')
    for comment in comments:
        comment_html = get_element_html(comment)
        story['comments'].append({
            'author': comment.get('author', ''),
            'created': comment.get('created', ''),
            'text': clean_html(comment_html)
        })
    
    # Extract custom fields
    custom_fields = item.findall('.//customfield')
    for field in custom_fields:
        field_name = field.findtext('customfieldname', '')
        field_values = field.findall('.//customfieldvalue')
        
        if field_values:
            # Combine all values, using get_element_html to handle nested HTML
            values = [clean_html(get_element_html(v)) for v in field_values if get_element_html(v).strip()]
            if values:
                story['custom_fields'][field_name] = '\n\n'.join(values)
    
    # Extract issue links
    story['linked_issues'] = {
        'milestone': [],
        'tasks': [],
        'blocks': [],
        'blocked_by': []
    }
    
    issuelinks = item.findall('.//issuelink')
    for link in issuelinks:
        issue_key = link.findtext('issuekey', '')
        if issue_key:
            # Determine link type based on parent structure
            parent = link.find('..')
            if parent is not None:
                link_desc = parent.get('description', '')
                if 'milestone' in link_desc.lower():
                    story['linked_issues']['milestone'].append(issue_key)
                elif 'task' in link_desc.lower():
                    story['linked_issues']['tasks'].append(issue_key)
    
    return story



def generate_markdown(story):
    """Generate Markdown content from story data."""
    md_lines = []
    
    # Frontmatter
    md_lines.append('---')
    md_lines.append(f'story_id: {story["key"]}')
    md_lines.append(f'title: {story["title"]}')
    md_lines.append(f'status: {story["status"]}')
    md_lines.append(f'priority: {story["priority"]}')
    md_lines.append(f'assignee: {story["assignee"]}')
    md_lines.append(f'type: {story["type"]}')
    md_lines.append(f'created: {story["created"]}')
    md_lines.append(f'updated: {story["updated"]}')
    if story['labels']:
        md_lines.append(f'labels: [{", ".join(story["labels"])}]')
    md_lines.append(f'jira_link: {story["link"]}')
    md_lines.append('---')
    md_lines.append('')
    
    # Title
    md_lines.append(f'# [{story["key"]}] {story["title"]}')
    md_lines.append('')
    
    # Description
    if story['description']:
        md_lines.append('## Description')
        md_lines.append('')
        md_lines.append(story['description'])
        md_lines.append('')
    
    # Acceptance Criteria
    if 'Acceptance Criteria (RT)' in story['custom_fields']:
        md_lines.append('## Acceptance Criteria')
        md_lines.append('')
        md_lines.append(story['custom_fields']['Acceptance Criteria (RT)'])
        md_lines.append('')
    
    # Implementation Steps
    if 'Implementation Steps' in story['custom_fields']:
        md_lines.append('## Implementation Steps')
        md_lines.append('')
        md_lines.append(story['custom_fields']['Implementation Steps'])
        md_lines.append('')
    
    # Solution Design
    if 'Solution Design' in story['custom_fields']:
        md_lines.append('## Solution Design')
        md_lines.append('')
        md_lines.append(story['custom_fields']['Solution Design'])
        md_lines.append('')
    
    # Deployment Checklist
    if 'Deployment Checklist' in story['custom_fields']:
        md_lines.append('## Deployment Checklist')
        md_lines.append('')
        md_lines.append(story['custom_fields']['Deployment Checklist'])
        md_lines.append('')
    
    # Notes
    if 'Notes' in story['custom_fields']:
        md_lines.append('## Notes')
        md_lines.append('')
        md_lines.append(story['custom_fields']['Notes'])
        md_lines.append('')
    
    # Linked Issues
    if any(story['linked_issues'].values()):
        md_lines.append('## Linked Issues')
        md_lines.append('')
        if story['linked_issues']['milestone']:
            md_lines.append('**Milestone:**')
            for issue in story['linked_issues']['milestone']:
                md_lines.append(f'- {issue}')
            md_lines.append('')
        if story['linked_issues']['tasks']:
            md_lines.append('**Tasks:**')
            for issue in story['linked_issues']['tasks']:
                md_lines.append(f'- {issue}')
            md_lines.append('')
    
    # Time Tracking
    if story['time_estimate'] or story['time_spent']:
        md_lines.append('## Time Tracking')
        md_lines.append('')
        if story['time_estimate']:
            md_lines.append(f'- **Remaining Estimate:** {story["time_estimate"]}')
        if story['time_spent']:
            md_lines.append(f'- **Time Spent:** {story["time_spent"]}')
        md_lines.append('')
    
    # Comments
    if story['comments']:
        md_lines.append('## Comments')
        md_lines.append('')
        for comment in story['comments']:
            md_lines.append(f'**{comment["author"]}** - {comment["created"]}')
            md_lines.append('')
            md_lines.append(comment['text'])
            md_lines.append('')
            md_lines.append('---')
            md_lines.append('')
    
    return '\n'.join(md_lines)



def convert_xml_to_md(xml_file_path, output_dir):
    """Convert a JIRA XML file to Markdown."""
    # Read XML file
    with open(xml_file_path, 'r', encoding='utf-8') as f:
        xml_content = f.read()
    
    # Parse XML
    story = parse_jira_xml(xml_content)
    
    # Determine output directory based on status
    status = story['status'].lower()
    if 'progress' in status:
        status_dir = 'in-progress'
    elif 'done' in status or 'complete' in status or 'resolved' in status:
        status_dir = 'completed'
    else:
        status_dir = 'backlog'
    
    # Create output directory
    output_path = Path(output_dir) / status_dir
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Generate Markdown
    md_content = generate_markdown(story)
    
    # Write to file
    output_file = output_path / f"{story['key']}.md"
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(md_content)
    
    print(f"✓ Converted {story['key']} to {output_file}")
    return output_file



if __name__ == '__main__':
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python jira_xml_to_md.py <xml_file> [output_dir]")
        sys.exit(1)
    
    xml_file = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else './docs/02-requirements'
    
    convert_xml_to_md(xml_file, output_dir)
