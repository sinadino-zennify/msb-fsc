/*
 * DAO Wizard Applicant Form Filler
 * --------------------------------
 * Paste this script into the browser console while on the Applicant Details step.
 * It populates applicant fields based on the DATA map below.
 * Use window.DAO_WIZARD_APPLICANT_FILLER.logLabels() to inspect available labels.
 * 
 * Based on the actual field structure from applicantDetails component.
 */

(() => {
    const normalize = label => (label || '')
        .replace(/\*/g, '')
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase();

    // Data structure matching the console log output from applicantDetails component
    const DATA = {
        // Personal Identity
        'salutation': 'Mr.',
        'first name': 'Joseph',
        'middle name': 'Scott',
        'last name': 'Trueman',
        'suffix': 'Jr.',
        'nickname': 'Joe',
        'date of birth': '1998-11-11',
        "mother's maiden name": 'Teixeira',
        
        // Tax Information
        'tax id type': 'SSN',
        'tax id number (ssn/itin)': '888-55-8989',
        
        // Citizenship Status
        'us citizen': 'No',
        'us resident': 'No',
        'country of residence': 'Canada',
        
        // Employment Information
        'employer': 'Zenn Lab',
        'occupation': 'Employed',
        
        // Organization Roles
        'organization role': 'Business Owner',
        'ownership percentage (%)': '50.00', // Note: field label includes (%) now
        'ownership percentage': '50.00', // Also support without (%) for backward compatibility
        
        // Contact Information
        'email': 'ze@mail.com',
        'mobile phone': '8885558978',
        'home phone': '8858888989',
        'work phone': '9995552525',
        
        // Mailing Address (these are skipped in the current implementation, but included for reference)
        // 'street address line 1': '3336 Kennelworth Lane',
        // 'street address line 2': 'House',
        // 'city': 'Bonita',
        // 'state': 'CA',
        // 'zip code': '91902',
        // 'country': 'United States',
        
        // Identity Documents (handled separately via modal)
        // These will need manual interaction or additional script logic
        // 'id type': 'Passport',
        // 'id number': '324234234',
        // 'issued by (state, country)': 'CT, USA',
        // 'issue date': '2025-11-01',
        // 'expiration date': '2025-11-25'
    };

    const fire = (el, type, detail) => {
        const init = { bubbles: true, composed: true };
        if (detail) Object.assign(init, { detail });
        const Ctor = type === 'change' && detail ? CustomEvent : Event;
        el.dispatchEvent(new Ctor(type, init));
    };

    const setVal = (el, value, normLabel) => {
        const tag = el.tagName;
        try {
            if (tag === 'LIGHTNING-INPUT' || tag === 'LIGHTNING-TEXTAREA') {
                el.value = value;
                fire(el, 'input');
                fire(el, 'change');
                return true;
            }
            if (tag === 'LIGHTNING-COMBOBOX') {
                el.value = value;
                fire(el, 'change', { value });
                return true;
            }
            if (tag === 'LIGHTNING-RADIO-GROUP') {
                el.value = value;
                fire(el, 'change', { value });
                return true;
            }
        } catch (err) {
            console.warn('⚠️ Unable to set value for', el, err);
        }
        return false;
    };

    const contextFor = el => {
        const owner = (node => {
            while (node && !node.tagName?.startsWith('C-')) {
                node = node.parentNode || node.host;
            }
            return node;
        })(el);
        // Only process elements within applicant details component
        if (owner?.tagName === 'C-APPLICANT-DETAILS') return 'applicant';
        return null; // Skip elements outside applicant details
    };

    const collect = (root, selector, visited = new Set()) => {
        const results = [];
        const stack = [root];
        while (stack.length) {
            const node = stack.pop();
            if (!node || visited.has(node)) continue;
            visited.add(node);

            if (node.querySelectorAll) {
                node.querySelectorAll(selector).forEach(el => results.push(el));
            }

            const childNodes = node instanceof ShadowRoot ? node.childNodes : node.childNodes;
            if (childNodes && childNodes.length) {
                Array.from(childNodes).forEach(child => {
                    if (child?.shadowRoot) {
                        stack.push(child.shadowRoot);
                    }
                    stack.push(child);
                });
            }
        }
        return results;
    };

    // Skip lightning-input-address as it's not handled in the current implementation
    const selector = 'lightning-input, lightning-textarea, lightning-combobox, lightning-radio-group';
    const candidates = collect(document, selector);

    const state = {
        filled: 0,
        skipped: 0,
        unmatched: []
    };

    const labelOf = el => {
        const label = el.label || el.getAttribute('label') || '';
        if (label) return label;
        // fallback: look for aria-label or associated label element
        return el.getAttribute('aria-label') || '';
    };

    candidates.forEach(el => {
        const context = contextFor(el);
        if (context !== 'applicant') {
            state.skipped++;
            return;
        }

        const rawLabel = labelOf(el);
        const normLabel = normalize(rawLabel);
        if (!normLabel) {
            state.skipped++;
            return;
        }
        
        // Try exact match first
        let value = DATA[normLabel];
        
        // Handle variations in ownership percentage label
        if (value == null) {
            // Try without trailing (%) or (%) variations
            const variations = [
                normLabel.replace(/\s*\(\s*%\s*\)\s*$/i, ''), // Remove (%) at end (any spacing)
                normLabel.replace(' (%)', ''),
                normLabel.replace('(%)', '')
            ];
            for (const variant of variations) {
                if (DATA[variant] != null) {
                    value = DATA[variant];
                    break;
                }
            }
        }
        
        if (value == null) {
            state.unmatched.push({ label: rawLabel, normalized: normLabel, tag: el.tagName });
            state.skipped++;
            return;
        }
        if (setVal(el, value, normLabel)) {
            state.filled++;
        } else {
            state.skipped++;
        }
    });

    const helper = {
        logLabels: () => {
            const rows = candidates
                .filter(el => contextFor(el) === 'applicant')
                .map(el => {
                    const label = labelOf(el);
                    return {
                        label: label || '[No label]',
                        normalized: label ? normalize(label) : '[N/A]',
                        tag: el.tagName
                    };
                });
            console.table(rows);
        },
        getData: () => DATA,
        setData: (newData) => {
            Object.assign(DATA, newData);
            console.log('✅ Data updated. Re-run the script to apply changes.');
        },
        // Helper to add identity document (requires manual modal interaction)
        addIdentityDocument: (docData) => {
            console.log('ℹ️ Identity documents must be added manually via the "Add ID" button.');
            console.log('Document data:', docData);
        }
    };

    window.DAO_WIZARD_APPLICANT_FILLER = helper;

    if (state.unmatched.length) {
        console.groupCollapsed('⚠️ Unmatched labels');
        console.table(state.unmatched);
        console.groupEnd();
    }

    console.log(`✅ Applicant form filler complete. Filled ${state.filled} field(s), skipped ${state.skipped}.`);
    console.log('Use window.DAO_WIZARD_APPLICANT_FILLER.logLabels() to inspect all detectable labels.');
    console.log('Use window.DAO_WIZARD_APPLICANT_FILLER.getData() to view current data.');
    console.log('Use window.DAO_WIZARD_APPLICANT_FILLER.setData({...}) to update data.');
    console.log('ℹ️ Note: Address fields and Identity Documents require manual interaction.');
})();

