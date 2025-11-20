/*
 * DAO Wizard Additional Applicants Form Filler
 * --------------------------------------------
 * Paste this script into the browser console while on the Additional Applicants step.
 * It automatically opens the modal and populates applicant fields.
 * Use window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.logLabels() to inspect available labels.
 * 
 * Usage:
 * 1. Run the script - it will automatically click "Add Additional Applicant"
 * 2. Wait for modal to open
 * 3. Fields will be auto-populated
 * 4. Optionally click "Add Applicant" manually or use helper.clickAddApplicant()
 */

(() => {
    const normalize = label => (label || '')
        .replace(/\*/g, '')
        .replace(/\s+/g, ' ')
        .trim()
        .toLowerCase();

    // Data structure for additional applicant
    const DATA = {
        // Personal Identity
        'salutation': 'Ms.',
        'first name': 'Jane',
        'middle name': 'Marie',
        'last name': 'Smith',
        'suffix': 'Sr.',
        'nickname': 'Janie',
        'date of birth': '1985-05-15',
        "mother's maiden name": 'Johnson',
        
        // Tax Information
        'tax id type': 'SSN',
        'tax id (ssn/ein/itin)': '123456789',
        
        // Citizenship Status
        'is us citizen': 'Yes',
        // 'is us resident': 'Yes', // Only shown if US Citizen = No
        // 'country of residence': 'Canada', // Only shown if US Resident = No
        
        // Employment Information
        'employer': 'Tech Corp',
        'occupation': 'Software Engineer',
        
        // Organization Roles
        'organization role': 'Partner',
        'ownership percentage (%)': '25.00',
        'ownership percentage': '25.00', // Backward compatibility
        'is control person': 'No',
        
        // Contact Information
        'email': 'jane.smith@example.com',
        'mobile phone': '5551234567',
        'home phone': '5559876543',
        'work phone': '5555555555'
        
        // Note: Address fields and Identity Documents require manual interaction
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
                console.log(`✅ Set ${normLabel} = "${value}" (${tag})`);
                return true;
            }
            if (tag === 'LIGHTNING-COMBOBOX') {
                el.value = value;
                fire(el, 'change', { value });
                console.log(`✅ Set ${normLabel} = "${value}" (${tag})`);
                return true;
            }
            if (tag === 'LIGHTNING-DUAL-LISTBOX') {
                el.value = Array.isArray(value) ? value : [value];
                fire(el, 'change', { value: el.value });
                console.log(`✅ Set ${normLabel} = "${el.value}" (${tag})`);
                return true;
            }
        } catch (err) {
            console.warn('⚠️ Unable to set value for', normLabel, el, err);
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
        // Only process elements within additional applicants component
        if (owner?.tagName === 'C-ADDITIONAL-APPLICANTS') return 'additional-applicants';
        return null;
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

    const labelOf = el => {
        const label = el.label || el.getAttribute('label') || '';
        if (label) return label;
        return el.getAttribute('aria-label') || '';
    };

    const fillForm = () => {
        console.log('🔍 Starting to fill additional applicant form...');
        console.log('🔍 Checking if modal is visible...');
        
        const modal = document.querySelector('.slds-modal.slds-fade-in-open') || 
                     document.querySelector('section[role="dialog"]') ||
                     document.querySelector('.slds-modal');
        
        if (!modal || modal.offsetParent === null) {
            console.warn('⚠️ Modal not found or not visible. Make sure the modal is open.');
            console.log('💡 Try clicking "Add Additional Applicant" first, then run:');
            console.log('   window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.fillForm()');
            return { filled: 0, skipped: 0, unmatched: [] };
        }
        
        console.log('✅ Modal is visible, proceeding to fill form...');
        
        const selector = 'lightning-input, lightning-textarea, lightning-combobox, lightning-dual-listbox';
        const candidates = collect(document, selector);
        
        console.log(`📊 Total candidates found: ${candidates.length}`);
        
        const additionalApplicantsCandidates = candidates.filter(el => contextFor(el) === 'additional-applicants');
        console.log(`📊 Additional Applicants context candidates: ${additionalApplicantsCandidates.length}`);
        
        const state = {
            filled: 0,
            skipped: 0,
            unmatched: []
        };

        candidates.forEach(el => {
            const context = contextFor(el);
            if (context !== 'additional-applicants') {
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
                const variations = [
                    normLabel.replace(/\s*\(\s*%\s*\)\s*$/i, ''),
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

        console.log('🔍 Form filling complete.');
        
        if (state.unmatched.length) {
            console.groupCollapsed('⚠️ Unmatched labels');
            console.table(state.unmatched);
            console.groupEnd();
        }

        console.log(`✅ Filled ${state.filled} field(s), skipped ${state.skipped}.`);
        return state;
    };

    const openModal = () => {
        console.log('🔍 Looking for "Add Additional Applicant" button...');
        const buttons = collect(document, 'lightning-button');
        const addButton = buttons.find(btn => {
            const label = btn.label || btn.textContent || '';
            return label.toLowerCase().includes('add additional applicant');
        });
        
        if (addButton) {
            console.log('✅ Found "Add Additional Applicant" button, clicking...');
            addButton.click();
            return true;
        } else {
            console.warn('⚠️ Could not find "Add Additional Applicant" button');
            return false;
        }
    };

    const waitForModal = (callback, maxAttempts = 20, attempt = 0) => {
        if (attempt >= maxAttempts) {
            console.error('❌ Modal did not appear after maximum attempts');
            console.log('💡 The modal is likely open. Running fillForm() now...');
            console.log('');
            // Just try to fill - the modal is probably there but in shadow DOM
            setTimeout(() => callback(), 500);
            return;
        }
        
        // Use our collect function to traverse shadow DOM and find modal inputs
        const allInputs = collect(document, 'lightning-input, lightning-combobox, lightning-dual-listbox');
        const modalInputs = allInputs.filter(el => {
            // Check if element is inside additional-applicants component
            return contextFor(el) === 'additional-applicants';
        });
        
        if (modalInputs.length > 10) { // Modal has many fields, so should be > 10
            console.log(`✅ Modal detected with ${modalInputs.length} input fields (attempt ${attempt + 1}), filling form in 1 second...`);
            setTimeout(() => callback(), 1000); // Give it a full second to render
        } else {
            if (attempt % 5 === 0) { // Log every 5th attempt to reduce noise
                console.log(`⏳ Waiting for modal... (attempt ${attempt + 1}/${maxAttempts}, found ${modalInputs.length} fields)`);
            }
            setTimeout(() => waitForModal(callback, maxAttempts, attempt + 1), 500);
        }
    };

    const helper = {
        logLabels: () => {
            const selector = 'lightning-input, lightning-textarea, lightning-combobox, lightning-dual-listbox';
            const candidates = collect(document, selector);
            const rows = candidates
                .filter(el => contextFor(el) === 'additional-applicants')
                .map(el => {
                    const label = labelOf(el);
                    const normLabel = normalize(label);
                    const hasData = DATA[normLabel] != null;
                    return {
                        label: label || '[No label]',
                        normalized: normLabel || '[N/A]',
                        tag: el.tagName,
                        hasData: hasData ? '✅' : '❌',
                        dataValue: hasData ? DATA[normLabel] : 'N/A'
                    };
                });
            console.table(rows);
        },
        getData: () => DATA,
        setData: (newData) => {
            Object.assign(DATA, newData);
            console.log('✅ Data updated. Re-run the script to apply changes.');
        },
        fillForm: () => {
            console.log('🔄 Manually filling form...');
            return fillForm();
        },
        openModalAndFill: () => {
            console.log('🔄 Opening modal and filling form...');
            if (openModal()) {
                waitForModal(fillForm);
            }
        },
        clickAddApplicant: () => {
            console.log('🔍 Looking for "Add Applicant" button in modal...');
            const buttons = collect(document, 'lightning-button');
            const addButton = buttons.find(btn => {
                const label = btn.label || btn.textContent || '';
                return label.toLowerCase().includes('add applicant') && !label.toLowerCase().includes('additional');
            });
            
            if (addButton) {
                console.log('✅ Found "Add Applicant" button, clicking...');
                addButton.click();
                return true;
            } else {
                console.warn('⚠️ Could not find "Add Applicant" button');
                return false;
            }
        },
        checkCurrentValues: () => {
            console.log('🔍 Checking current field values in the modal...');
            const selector = 'lightning-input, lightning-textarea, lightning-combobox, lightning-dual-listbox';
            const candidates = collect(document, selector);
            const additionalApplicantsFields = candidates.filter(el => contextFor(el) === 'additional-applicants');
            const currentValues = additionalApplicantsFields.map(el => {
                const label = labelOf(el);
                return {
                    label: label || '[No label]',
                    normalized: normalize(label),
                    currentValue: el.value || '[empty]',
                    expectedValue: DATA[normalize(label)] || '[no data]'
                };
            });
            console.table(currentValues);
        }
    };

    window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER = helper;

    // Auto-run: Open modal and fill form
    console.log('🚀 DAO Wizard Additional Applicants Form Filler initialized');
    console.log('');
    console.log('🎯 RECOMMENDED: Manual 2-Step Process');
    console.log('  1. Click "Add Additional Applicant" button manually');
    console.log('  2. Run: window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.fillForm()');
    console.log('');
    console.log('📋 Available commands:');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.fillForm() - Fill form (if modal already open) ⭐');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.openModalAndFill() - Auto open modal and fill');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.clickAddApplicant() - Click "Add Applicant" button');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.logLabels() - Inspect all detectable labels');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.checkCurrentValues() - Check current vs expected values');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.getData() - View current data');
    console.log('  - window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.setData({...}) - Update data');
    console.log('');
    console.log('🔄 Auto-opening modal and filling form in 3 seconds...');
    console.log('   (Or click the button manually and run fillForm() for faster results)');
    
    setTimeout(() => {
        console.log('');
        console.log('🚀 Starting auto-fill process...');
        if (openModal()) {
            waitForModal(fillForm);
        } else {
            console.log('💡 Button not found. Try the manual approach:');
            console.log('   1. Click "Add Additional Applicant" button');
            console.log('   2. Run: window.DAO_WIZARD_ADDITIONAL_APPLICANTS_FILLER.fillForm()');
        }
    }, 3000);
})();

