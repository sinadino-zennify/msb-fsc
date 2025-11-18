/*
 * DAO Wizard Business Form Filler
 * -------------------------------
 * Paste this script into the browser console while on the Business Details step.
 * It populates business fields based on the DATA map below.
 * Use window.DAO_WIZARD_BUSINESS_FILLER.logLabels() to inspect available labels.
 */

(() => {
    const normalize = label => (label || '')
        .replace(/\*/g, '')
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase();

    const DATA = {
        'business account': 'new',
        'legal business name': 'Acme Widgets LLC',
        'dba name (doing business as)': 'Acme Widgets',
        'business type': 'LLC',
        'federal tax id (ein)': '12-3456789',
        'date established': '2019-03-15',
        'state of incorporation': 'California',
        'industry type': 'Technology',
        'business description': 'Automated test data via console filler script.',
        'business phone': '555-555-5555',
        'business email': 'info@acmewidgets.example',
        'business phone (home)': '555-555-5556',
        'business phone (mobile)': '555-555-5557',
        'business website': 'https://www.acmewidgets.example',
        'primary contact name': 'Jane Doe',
        'primary contact title': 'CFO',
        'annual revenue': '750000',
        'number of employees': '51-100',
        'street address line 1': '500 Market Street',
        'street address line 2': 'Suite 1200',
        'city': 'San Francisco',
        'state': 'California',
        'zip code': '94105',
        'country': 'USA'
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
        // Only process elements within business details component
        if (owner?.tagName === 'C-BUSINESS-DETAILS') return 'business';
        return null; // Skip elements outside business details
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
        if (context !== 'business') {
            state.skipped++;
            return;
        }

        const rawLabel = labelOf(el);
        const normLabel = normalize(rawLabel);
        if (!normLabel) {
            state.skipped++;
            return;
        }
        
        const value = DATA[normLabel];
        
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
                .filter(el => contextFor(el) === 'business')
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
        }
    };

    window.DAO_WIZARD_BUSINESS_FILLER = helper;

    if (state.unmatched.length) {
        console.groupCollapsed('⚠️ Unmatched labels');
        console.table(state.unmatched);
        console.groupEnd();
    }

    console.log(`✅ Business form filler complete. Filled ${state.filled} field(s), skipped ${state.skipped}.`);
    console.log('Use window.DAO_WIZARD_BUSINESS_FILLER.logLabels() to inspect all detectable labels.');
    console.log('Use window.DAO_WIZARD_BUSINESS_FILLER.getData() to view current data.');
    console.log('Use window.DAO_WIZARD_BUSINESS_FILLER.setData({...}) to update data.');
})();

