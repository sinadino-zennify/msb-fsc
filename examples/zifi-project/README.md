# ZiFi Project - Reference Implementation

This directory contains a reference implementation from the ZiFi deposit account opening project.

---

## 📋 Purpose

Use this as a working example to understand:
- How field mappings are structured
- How workflows are documented
- How to organize API integration
- Real-world patterns and solutions

---

## 🔍 What's Included

### Field Mappings Example
- `dao-field-mappings.csv` - Complete field mapping from ZiFi project
- Shows how to map 100+ fields across applicant/business/application objects

### Key Learnings

1. **Address Handling**: ZiFi uses PersonMailing* for home address, PersonOther* for mailing address
2. **Ownership Structure**: Multiple beneficial owners tracked via AccountContactRelation
3. **External IDs**: Consistent naming pattern (DAOApplicationId__c, DAOApplicantId__c, etc.)
4. **CSV Structure**: Comments column used for implementation notes

---

## 🎯 How to Use This Example

1. **Review the CSV**: See how fields are organized and documented
2. **Study the patterns**: Notice naming conventions and grouping
3. **Adapt to your needs**: Your integration may have different fields
4. **Don't copy blindly**: Understand the WHY behind each mapping

---

## ⚠️ Important Notes

- This is **reference only** - not meant to be used as-is
- Your {{INTEGRATION_SOURCE}} integration will have different fields
- Use this to understand structure and patterns
- Sanitized to remove any sensitive data

---

## 📚 Related Documentation

- ZiFi ADRs: `/docs/04-implementation/architecture-decisions/ADR-0001-phase-1-data-foundation.md`
- ZiFi Workflows: `/docs/03-workflows/sole-prop.md` and `other-entities.md`

---

**Source Project**: ZiFi Salesforce  
**Date**: January 2025  
**Purpose**: DAO Integration for deposit account opening

