/*
 * DAO Wizard Form Filler
 * -----------------------
 * Paste this script into the browser console while the DAO wizard is open.
 * It populates both Business and Applicant steps based on the DATA map below.
 * Use window.DAO_WIZARD_FILLER.logLabels() to inspect available labels.
 */

(() => {
    const normalize = label => (label || '')
        .replace(/\*/g, '')
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase();

    const DATA = {
        shared: {
            'country': 'USA'
        },
        business: {
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
            'zip code': '94105'
        },
        applicant: {
            'salutation': 'Mr.',
            'first name': 'John',
            'last name': 'Smith',
            'tax id number (ssn/itin)': '888-88-4554',
            'tax id type': 'SSN',
            'date of birth': '1990-02-10',
            'email': 'john.smith@example.com',
            'mobile phone': '555-666-8989',
            'home phone': '555-111-2222',
            'work phone': '555-333-4444',
            'street address line 1': '333 Bush Street',
            'street address line 2': 'Apt 5A',
            'city': 'San Francisco',
            'state': 'California',
            'zip code': '94104',
            'country': 'USA',
            'id type': "Driver's License",
            'id number': 'S1234567',
            'issued by - country': 'USA',
            'issued by - state': 'California',
            'issue date': '2021-05-01',
            'expiration date': '2029-05-01'
        }
    };

    const fire = (el, type, detail) => {
        const init = { bubbles: true, composed: true };
        if (detail) Object.assign(init, { detail });
        const Ctor = type === 'change' && detail ? CustomEvent : Event;
        el.dispatchEvent(new Ctor(type, init));
    };

    const setVal = (el, value) => {
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
        if (owner?.tagName === 'C-APPLICANT-DETAILS') return 'applicant';
        if (owner?.tagName === 'C-BUSINESS-DETAILS') return 'business';
        return 'shared';
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
        const rawLabel = labelOf(el);
        const normLabel = normalize(rawLabel);
        if (!normLabel) {
            state.skipped++;
            return;
        }
        const context = contextFor(el);
        const value = DATA[context]?.[normLabel] ?? DATA.shared[normLabel];
        if (value == null) {
            state.unmatched.push({ label: rawLabel, normalized: normLabel, context, tag: el.tagName });
            state.skipped++;
            return;
        }
        if (setVal(el, value)) {
            state.filled++;
        } else {
            state.skipped++;
        }
    });

    const helper = {
        logLabels: () => {
            const rows = candidates.map(el => ({
                label: labelOf(el),
                normalized: normalize(labelOf(el)),
                context: contextFor(el),
                tag: el.tagName
            }));
            console.table(rows);
        }
    };

    window.DAO_WIZARD_FILLER = helper;

    if (state.unmatched.length) {
        console.groupCollapsed('⚠️ Unmatched labels');
        console.table(state.unmatched);
        console.groupEnd();
    }

    console.log(`Wizard form filler complete. Filled ${state.filled} field(s), skipped ${state.skipped}.`);
    console.log('Use window.DAO_WIZARD_FILLER.logLabels() to inspect all detectable labels.');
})();
