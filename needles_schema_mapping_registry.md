# Schema Flow Mapping Registry

This table provides a mapping of Source Tables to Target Screens, automatically generated from SQL script filenames.

| Script                                          | Source Tables    | Target Screens                          | Path                                                                                 |
|:------------------------------------------------|:-----------------|:----------------------------------------|:-------------------------------------------------------------------------------------|
| 3.20_plaintiff_udf.sql                          |                  | 3.20_plaintiff_udf                      | scripts/needles/conversion/2_case/dev/3.20_plaintiff_udf.sql                         |
| 3.21_incident_udf.sql                           |                  | 3.21_incident_udf                       | scripts/needles/conversion/2_case/dev/3.21_incident_udf.sql                          |
| 4.00_std_Calendar.sql                           |                  | 4.00_std_Calendar                       | scripts/needles/conversion/3_misc/4.00_std_Calendar.sql                              |
| 4.00_std_DefaultDefendant.sql                   |                  | 4.00_std_DefaultDefendant               | scripts/needles/conversion/3_misc/4.00_std_DefaultDefendant.sql                      |
| 4.01_std_User-Contact.sql                       |                  | 4.01_std_User-Contact                   | scripts/needles/conversion/3_misc/4.01_std_User-Contact.sql                          |
| 4.02_std_CaseNames.sql                          |                  | 4.02_std_CaseNames                      | scripts/needles/conversion/3_misc/4.02_std_CaseNames.sql                             |
| 4.03_std_OtherCaseRelatedContacts.sql           |                  | 4.03_std_OtherCaseRelatedContacts       | scripts/needles/conversion/3_misc/4.03_std_OtherCaseRelatedContacts.sql              |
| 4.05_std_Miscellany.sql                         |                  | 4.05_std_Miscellany                     | scripts/needles/conversion/3_misc/4.05_std_Miscellany.sql                            |
| 5.00_intake_cases.sql                           |                  | 5.00_intake_cases                       | scripts/needles/conversion/4_intake/5.00_intake_cases.sql                            |
| 5.02_intake_CaseStaff.sql                       |                  | 5.02_intake_CaseStaff                   | scripts/needles/conversion/4_intake/5.02_intake_CaseStaff.sql                        |
| 5.02_intake_Incident.sql                        |                  | 5.02_intake_Incident                    | scripts/needles/conversion/4_intake/5.02_intake_Incident.sql                         |
| 5.07_intake_ReferredBy.sql                      |                  | 5.07_intake_ReferredBy                  | scripts/needles/conversion/4_intake/5.07_intake_ReferredBy.sql                       |
| 5.08_intake_updateContactAddress.sql            |                  | 5.08_intake_updateContactAddress        | scripts/needles/conversion/4_intake/5.08_intake_updateContactAddress.sql             |
| 5.09_intake_Plaintiffs.sql                      |                  | 5.09_intake_Plaintiffs                  | scripts/needles/conversion/4_intake/5.09_intake_Plaintiffs.sql                       |
| 00__schema__Address.sql                         | schema           | Address                                 | scripts/needles/.dev/00__schema__Address.sql                                         |
| 91__AllContactInfo.sql                          |                  | AllContactInfo                          | scripts/needles/conversion/1_contact/91__AllContactInfo.sql                          |
| counsel__Attorneys.sql                          | counsel          | Attorneys                               | scripts/needles/conversion/2_case/counsel__Attorneys.sql                             |
| calendar__Calendar_Case.sql                     | calendar         | Calendar_Case                           | scripts/needles/conversion/2_case/calendar__Calendar_Case.sql                        |
| Case Staff.sql                                  |                  | Case Staff                              | scripts/needles/mapping/Case Staff.sql                                               |
| Case Types.sql                                  |                  | Case Types                              | scripts/needles/mapping/Case Types.sql                                               |
| cases__CaseStaff.sql                            | cases            | CaseStaff                               | scripts/needles/conversion/2_case/cases__CaseStaff.sql                               |
| class__CaseStatus.sql                           | class            | CaseStatus                              | scripts/needles/conversion/2_case/class__CaseStatus.sql                              |
| create__CaseTypeMixture.sql                     | create           | CaseTypeMixture                         | scripts/needles/conversion/0_init/create__CaseTypeMixture.sql                        |
| 01__CaseTypeMap__CaseTypes.sql                  | CaseTypeMap      | CaseTypes                               | scripts/needles/conversion/2_case/01__CaseTypeMap__CaseTypes.sql                     |
| cases__CaseUDF.sql                              | cases            | CaseUDF                                 | scripts/needles/conversion/2_case/cases__CaseUDF.sql                                 |
| user_case__CaseUDF.sql                          | user_case        | CaseUDF                                 | scripts/needles/conversion/2_case/user_case__CaseUDF.sql                             |
| user_tab5__CaseUDF (2).sql                      | user_tab5        | CaseUDF (2)                             | scripts/needles/conversion/2_case/dev/user_tab5__CaseUDF (2).sql                     |
| insurance__CaseValue.sql                        | insurance        | CaseValue                               | scripts/needles/conversion/2_case/insurance__CaseValue.sql                           |
| create__CaseValueMapping.sql                    | create           | CaseValueMapping                        | scripts/needles/conversion/0_init/create__CaseValueMapping.sql                       |
| 00__schema__Cases.sql                           | schema           | Cases                                   | scripts/needles/.dev/00__schema__Cases.sql                                           |
| 03__cases__Cases.sql                            | cases            | Cases                                   | scripts/needles/conversion/2_case/03__cases__Cases.sql                               |
| 00__schema__ContactNumbers.sql                  | schema           | ContactNumbers                          | scripts/needles/.dev/00__schema__ContactNumbers.sql                                  |
| 00__schema__Courts.sql                          | schema           | Courts                                  | scripts/needles/.dev/00__schema__Courts.sql                                          |
| cases__Courts.sql                               | cases            | Courts                                  | scripts/needles/conversion/2_case/cases__Courts.sql                                  |
| cases__CriticalComments.sql                     | cases            | CriticalComments                        | scripts/needles/conversion/2_case/cases__CriticalComments.sql                        |
| cases__CriticalDeadlines.sql                    | cases            | CriticalDeadlines                       | scripts/needles/conversion/2_case/cases__CriticalDeadlines.sql                       |
| user_party__DefendantUDF.sql                    | user_party       | DefendantUDF                            | scripts/needles/conversion/2_case/user_party__DefendantUDF.sql                       |
| user_party__DefendantUDF.sql                    | user_party       | DefendantUDF                            | scripts/needles/conversion/2_case/dev/user_party__DefendantUDF.sql                   |
| 00__schema__Defendants.sql                      | schema           | Defendants                              | scripts/needles/.dev/00__schema__Defendants.sql                                      |
| 05__party__Defendants.sql                       | party            | Defendants                              | scripts/needles/conversion/2_case/05__party__Defendants.sql                          |
| 00__schema__Disbursements.sql                   | schema           | Disbursements                           | scripts/needles/.dev/00__schema__Disbursements.sql                                   |
| value_tab__Disbursements.sql                    | value_tab        | Disbursements                           | scripts/needles/conversion/2_case/value_tab__Disbursements.sql                       |
| 00__schema__EmailWebsite.sql                    | schema           | EmailWebsite                            | scripts/needles/.dev/00__schema__EmailWebsite.sql                                    |
| user_party__Employment.sql                      | user_party       | Employment                              | scripts/needles/conversion/2_case/user_party__Employment.sql                         |
| cases__Incident.sql                             | cases            | Incident                                | scripts/needles/conversion/2_case/cases__Incident.sql                                |
| IncidentUDF.sql                                 |                  | IncidentUDF                             | scripts/needles/conversion/2_case/dev/IncidentUDF.sql                                |
| user_tab10__IncidentUDF.sql                     | user_tab10       | IncidentUDF                             | scripts/needles/conversion/4_intake/user_tab10__IncidentUDF.sql                      |
| 00__schema__IndvContacts.sql                    | schema           | IndvContacts                            | scripts/needles/.dev/00__schema__IndvContacts.sql                                    |
| 20__Address__IndvContacts.sql                   | Address          | IndvContacts                            | scripts/needles/conversion/1_contact/20__Address__IndvContacts.sql                   |
| 31__ContactNumbers__IndvContacts.sql            | ContactNumbers   | IndvContacts                            | scripts/needles/conversion/1_contact/31__ContactNumbers__IndvContacts.sql            |
| 40__EmailWebsite__IndvContacts.sql              | EmailWebsite     | IndvContacts                            | scripts/needles/conversion/1_contact/40__EmailWebsite__IndvContacts.sql              |
| 92__IndvOrgContacts_Indexed.sql                 |                  | IndvOrgContacts_Indexed                 | scripts/needles/conversion/1_contact/92__IndvOrgContacts_Indexed.sql                 |
| insurance__Insurance.sql                        | insurance        | Insurance                               | scripts/needles/conversion/2_case/insurance__Insurance.sql                           |
| 00__schema__InsuranceCoverage.sql               | schema           | InsuranceCoverage                       | scripts/needles/.dev/00__schema__InsuranceCoverage.sql                               |
| Intake.sql                                      |                  | Intake                                  | scripts/needles/mapping/Intake.sql                                                   |
| IntakeUDF.sql                                   |                  | IntakeUDF                               | scripts/needles/conversion/4_intake/IntakeUDF.sql                                    |
| police__Investigations.sql                      | police           | Investigations                          | scripts/needles/conversion/2_case/police__Investigations.sql                         |
| user_tab1__Investigations_CaseWitness.sql       | user_tab1        | Investigations_CaseWitness              | scripts/needles/conversion/2_case/user_tab1__Investigations_CaseWitness.sql          |
| 00__schema__LawFirms.sql                        | schema           | LawFirms                                | scripts/needles/.dev/00__schema__LawFirms.sql                                        |
| 00__schema__LienTracking.sql                    | schema           | LienTracking                            | scripts/needles/.dev/00__schema__LienTracking.sql                                    |
| user_tab3__LienTracking.sql                     | user_tab3        | LienTracking                            | scripts/needles/conversion/2_case/user_tab3__LienTracking.sql                        |
| value_tab__LienTracking.sql                     | value_tab        | LienTracking                            | scripts/needles/conversion/2_case/value_tab__LienTracking.sql                        |
| user_tab1__Litigation_Depositions.sql           | user_tab1        | Litigation_Depositions                  | scripts/needles/conversion/2_case/user_tab1__Litigation_Depositions.sql              |
| 00__schema__MedicalProviders.sql                | schema           | MedicalProviders                        | scripts/needles/.dev/00__schema__MedicalProviders.sql                                |
| value_tab__MedicalProviders.sql                 | value_tab        | MedicalProviders                        | scripts/needles/conversion/2_case/value_tab__MedicalProviders.sql                    |
| user_tab2__MedicalProviders_MedicalRequest.sql  | user_tab2        | MedicalProviders_MedicalRequest         | scripts/needles/conversion/2_case/user_tab2__MedicalProviders_MedicalRequest.sql     |
| create__NeedlesUserFields.sql                   | create           | NeedlesUserFields                       | scripts/needles/discovery/create__NeedlesUserFields.sql                              |
| create__NeedlesUserFields_intake.sql            | create           | NeedlesUserFields_intake                | scripts/needles/discovery/create__NeedlesUserFields_intake.sql                       |
| negotiations__Negotiations.sql                  | negotiations     | Negotiations                            | scripts/needles/conversion/2_case/negotiations__Negotiations.sql                     |
| 00__schema__Notes.sql                           | schema           | Notes                                   | scripts/needles/.dev/00__schema__Notes.sql                                           |
| notes__Notes.sql                                | notes            | Notes                                   | scripts/needles/conversion/2_case/notes__Notes.sql                                   |
| 00__schema__OrgContacts.sql                     | schema           | OrgContacts                             | scripts/needles/.dev/00__schema__OrgContacts.sql                                     |
| 21__Address__OrgContacts.sql                    | Address          | OrgContacts                             | scripts/needles/conversion/1_contact/21__Address__OrgContacts.sql                    |
| 32__ContactNumbers__OrgContacts.sql             | ContactNumbers   | OrgContacts                             | scripts/needles/conversion/1_contact/32__ContactNumbers__OrgContacts.sql             |
| 40__EmailWebsite__OrgContacts.sql               | EmailWebsite     | OrgContacts                             | scripts/needles/conversion/1_contact/40__EmailWebsite__OrgContacts.sql               |
| user_tab10__Other1UDF (IntakeUDF).sql           | user_tab10       | Other1UDF (IntakeUDF)                   | scripts/needles/conversion/2_case/user_tab10__Other1UDF (IntakeUDF).sql              |
| Party Roles.sql                                 |                  | Party Roles                             | scripts/needles/mapping/Party Roles.sql                                              |
| create__PartyRoles.sql                          | create           | PartyRoles                              | scripts/needles/conversion/0_init/create__PartyRoles.sql                             |
| user_tab9__PlaintifFUDF.sql                     | user_tab9        | PlaintifFUDF                            | scripts/needles/conversion/2_case/user_tab9__PlaintifFUDF.sql                        |
| 04__party__Plaintiff.sql                        | party            | Plaintiff                               | scripts/needles/conversion/2_case/04__party__Plaintiff.sql                           |
| 00__schema__PlaintiffAttorney.sql               | schema           | PlaintiffAttorney                       | scripts/needles/.dev/00__schema__PlaintiffAttorney.sql                               |
| user_party__PlaintiffUDF.sql                    | user_party       | PlaintiffUDF                            | scripts/needles/conversion/2_case/user_party__PlaintiffUDF.sql                       |
| 00__schema__Plaintiffs.sql                      | schema           | Plaintiffs                              | scripts/needles/.dev/00__schema__Plaintiffs.sql                                      |
| value_tab__Referral_Attorney.sql                | value_tab        | Referral_Attorney                       | scripts/needles/conversion/2_case/value_tab__Referral_Attorney.sql                   |
| cases__Referral_OtherReferral.sql               | cases            | Referral_OtherReferral                  | scripts/needles/conversion/2_case/cases__Referral_OtherReferral.sql                  |
| 20__Referral__ReferredOut.sql                   | Referral         | ReferredOut                             | scripts/needles/conversion/2_case/dev/20__Referral__ReferredOut.sql                  |
| companion_cases__RelatedCases.sql               | companion_cases  | RelatedCases                            | scripts/needles/conversion/2_case/companion_cases__RelatedCases.sql                  |
| 20__SOLChecklist.sql                            |                  | SOLChecklist                            | scripts/needles/conversion/2_case/dev/20__SOLChecklist.sql                           |
| 00__schema__Settlements.sql                     | schema           | Settlements                             | scripts/needles/.dev/00__schema__Settlements.sql                                     |
| value_tab__Settlements.sql                      | value_tab        | Settlements                             | scripts/needles/conversion/2_case/value_tab__Settlements.sql                         |
| 00__schema__SpDamages.sql                       | schema           | SpDamages                               | scripts/needles/.dev/00__schema__SpDamages.sql                                       |
| value_tab__SpDamages.sql                        | value_tab        | SpDamages                               | scripts/needles/conversion/2_case/value_tab__SpDamages.sql                           |
| 02__PartyRoleMap__SubRole.sql                   | PartyRoleMap     | SubRole                                 | scripts/needles/conversion/2_case/02__PartyRoleMap__SubRole.sql                      |
| 00__schema__TaskNew.sql                         | schema           | TaskNew                                 | scripts/needles/.dev/00__schema__TaskNew.sql                                         |
| case_checklist__Tasks.sql                       | case_checklist   | Tasks                                   | scripts/needles/conversion/2_case/case_checklist__Tasks.sql                          |
| user_tab5__UDF_Grid_1.sql                       | user_tab5        | UDF_Grid_1                              | scripts/needles/conversion/2_case/user_tab5__UDF_Grid_1.sql                          |
| 90__Uniqueness.sql                              |                  | Uniqueness                              | scripts/needles/conversion/1_contact/90__Uniqueness.sql                              |
| 00__schema__Users.sql                           | schema           | Users                                   | scripts/needles/.dev/00__schema__Users.sql                                           |
| 15__Users.sql                                   |                  | Users                                   | scripts/needles/conversion/1_contact/15__Users.sql                                   |
| Value Codes.sql                                 |                  | Value Codes                             | scripts/needles/mapping/Value Codes.sql                                              |
| _create_CustomFieldUsage.sql                    |                  | _create_CustomFieldUsage                | scripts/needles/.dev/_create_CustomFieldUsage.sql                                    |
| _create_CustomFieldUsage_intake.sql             |                  | _create_CustomFieldUsage_intake         | scripts/needles/.dev/_create_CustomFieldUsage_intake.sql                             |
| _dev_SOLChecklist.sql                           |                  | _dev_SOLChecklist                       | scripts/needles/conversion/2_case/dev/_dev_SOLChecklist.sql                          |
| 00__add_breadcrumbs_to_implementation_users.sql |                  | add_breadcrumbs_to_implementation_users | scripts/needles/conversion/1_contact/00__add_breadcrumbs_to_implementation_users.sql |
| 22__Address__appendix.sql                       | Address          | appendix                                | scripts/needles/conversion/1_contact/22__Address__appendix.sql                       |
| update__case_intake.sql                         | update           | case_intake                             | scripts/needles/discovery/update__case_intake.sql                                    |
| create__case_notes_indexed.sql                  | create           | case_notes_indexed                      | scripts/needles/discovery/create__case_notes_indexed.sql                             |
| create__cases_indexed.sql                       | create           | cases_indexed                           | scripts/needles/discovery/create__cases_indexed.sql                                  |
| create__checklist_dir_indexed.sql               | create           | checklist_dir_indexed                   | scripts/needles/discovery/create__checklist_dir_indexed.sql                          |
| 05__IndvContacts__comments.sql                  | IndvContacts     | comments                                | scripts/needles/conversion/1_contact/05__IndvContacts__comments.sql                  |
| 11__OrgContacts__comments.sql                   | OrgContacts      | comments                                | scripts/needles/conversion/1_contact/11__OrgContacts__comments.sql                   |
| 99__Notes__contacts.sql                         | Notes            | contacts                                | scripts/needles/conversion/1_contact/99__Notes__contacts.sql                         |
| create__counsel_indexed.sql                     | create           | counsel_indexed                         | scripts/needles/discovery/create__counsel_indexed.sql                                |
| 01__imp_user_map__create.sql                    | imp_user_map     | create                                  | scripts/needles/.dev/01__imp_user_map__create.sql                                    |
| dev_documents.sql                               |                  | dev_documents                           | scripts/needles/conversion/3_misc/dev/dev_documents.sql                              |
| 00__insert_fallback_contacts.sql                |                  | insert_fallback_contacts                | scripts/needles/conversion/1_contact/00__insert_fallback_contacts.sql                |
| 04__IndvContacts__insurance.sql                 | IndvContacts     | insurance                               | scripts/needles/conversion/1_contact/04__IndvContacts__insurance.sql                 |
| create__insurance_indexed.sql                   | create           | insurance_indexed                       | scripts/needles/discovery/create__insurance_indexed.sql                              |
| 01__IndvContacts__names.sql                     | IndvContacts     | names                                   | scripts/needles/conversion/1_contact/01__IndvContacts__names.sql                     |
| 10__OrgContacts__names.sql                      | OrgContacts      | names                                   | scripts/needles/conversion/1_contact/10__OrgContacts__names.sql                      |
| sa__office.sql                                  | sa               | office                                  | scripts/needles/conversion/0_init/sa__office.sql                                     |
| create__party_indexed.sql                       | create           | party_indexed                           | scripts/needles/discovery/create__party_indexed.sql                                  |
| 02__IndvContacts__police.sql                    | IndvContacts     | police                                  | scripts/needles/conversion/1_contact/02__IndvContacts__police.sql                    |
| sampleGridUDFInsert.sql                         |                  | sampleGridUDFInsert                     | scripts/needles/conversion/2_case/dev/sampleGridUDFInsert.sql                        |
| 03__IndvContacts__staff.sql                     | IndvContacts     | staff                                   | scripts/needles/conversion/1_contact/03__IndvContacts__staff.sql                     |
| udf__starter.sql                                | udf              | starter                                 | scripts/needles/conversion/2_case/dev/udf__starter.sql                               |
| update_contact_types.sql                        |                  | update_contact_types                    | scripts/needles/conversion/3_misc/update_contact_types.sql                           |
| CaseUDF__upgraded.sql                           | CaseUDF          | upgraded                                | scripts/needles/conversion/2_case/dev/CaseUDF__upgraded.sql                          |
| user_case_data.sql                              |                  | user_case_data                          | scripts/needles/mapping/user_case_data.sql                                           |
| user_counsel_data.sql                           |                  | user_counsel_data                       | scripts/needles/mapping/user_counsel_data.sql                                        |
| user_insurance_data.sql                         |                  | user_insurance_data                     | scripts/needles/mapping/user_insurance_data.sql                                      |
| user_party_base.sql                             |                  | user_party_base                         | scripts/needles/conversion/2_case/dev/user_party_base.sql                            |
| user_party_data.sql                             |                  | user_party_data                         | scripts/needles/mapping/user_party_data.sql                                          |
| Other1UDF__user_tab1.sql                        | Other1UDF        | user_tab1                               | scripts/needles/conversion/2_case/dev/Other1UDF__user_tab1.sql                       |
| Other10UDF__user_tab10.sql                      | Other10UDF       | user_tab10                              | scripts/needles/conversion/2_case/dev/Other10UDF__user_tab10.sql                     |
| user_tab10_data.sql                             |                  | user_tab10_data                         | scripts/needles/mapping/user_tab10_data.sql                                          |
| Other2UDF__user_tab2.sql                        | Other2UDF        | user_tab2                               | scripts/needles/conversion/2_case/dev/Other2UDF__user_tab2.sql                       |
| user_tab2_data.sql                              |                  | user_tab2_data                          | scripts/needles/mapping/user_tab2_data.sql                                           |
| Other3UDF__user_tab3.sql                        | Other3UDF        | user_tab3                               | scripts/needles/conversion/2_case/dev/Other3UDF__user_tab3.sql                       |
| user_tab3_data.sql                              |                  | user_tab3_data                          | scripts/needles/mapping/user_tab3_data.sql                                           |
| Other4UDF__user_tab4.sql                        | Other4UDF        | user_tab4                               | scripts/needles/conversion/2_case/dev/Other4UDF__user_tab4.sql                       |
| user_tab4_data.sql                              |                  | user_tab4_data                          | scripts/needles/mapping/user_tab4_data.sql                                           |
| Other5UDF__user_tab5.sql                        | Other5UDF        | user_tab5                               | scripts/needles/conversion/2_case/dev/Other5UDF__user_tab5.sql                       |
| user_tab5_data.sql                              |                  | user_tab5_data                          | scripts/needles/mapping/user_tab5_data.sql                                           |
| Other6UDF__user_tab6.sql                        | Other6UDF        | user_tab6                               | scripts/needles/conversion/2_case/dev/Other6UDF__user_tab6.sql                       |
| user_tab6_data.sql                              |                  | user_tab6_data                          | scripts/needles/mapping/user_tab6_data.sql                                           |
| Other7UDF__user_tab7.sql                        | Other7UDF        | user_tab7                               | scripts/needles/conversion/2_case/dev/Other7UDF__user_tab7.sql                       |
| user_tab7_data.sql                              |                  | user_tab7_data                          | scripts/needles/mapping/user_tab7_data.sql                                           |
| Other8UDF__user_tab8.sql                        | Other8UDF        | user_tab8                               | scripts/needles/conversion/2_case/dev/Other8UDF__user_tab8.sql                       |
| user_tab8_data.sql                              |                  | user_tab8_data                          | scripts/needles/mapping/user_tab8_data.sql                                           |
| Other9UDF__user_tab9.sql                        | Other9UDF        | user_tab9                               | scripts/needles/conversion/2_case/dev/Other9UDF__user_tab9.sql                       |
| user_tab9_data.sql                              |                  | user_tab9_data                          | scripts/needles/mapping/user_tab9_data.sql                                           |
| user_tab_base.sql                               |                  | user_tab_base                           | scripts/needles/conversion/2_case/dev/user_tab_base.sql                              |
| user_tab_data.sql                               |                  | user_tab_data                           | scripts/needles/mapping/user_tab_data.sql                                            |
| create__user_tab_map.sql                        | create           | user_tab_map                            | scripts/needles/discovery/create__user_tab_map.sql                                   |
| user_tab_map.sql                                |                  | user_tab_map                            | scripts/needles/mapping/user_tab_map.sql                                             |
| user_value_data.sql                             |                  | user_value_data                         | scripts/needles/mapping/user_value_data.sql                                          |
| 30__ContactNumbers__utility.sql                 | ContactNumbers   | utility                                 | scripts/needles/conversion/1_contact/30__ContactNumbers__utility.sql                 |
| 50__Disbursements__value.sql                    | Disbursements    | value                                   | scripts/needles/conversion/2_case/dev/50__Disbursements__value.sql                   |
| 50__LienTracking__value.sql                     | LienTracking     | value                                   | scripts/needles/conversion/2_case/dev/50__LienTracking__value.sql                    |
| 50__MedicalProviders__value.sql                 | MedicalProviders | value                                   | scripts/needles/conversion/2_case/dev/50__MedicalProviders__value.sql                |
| 50__Settlements__value.sql                      | Settlements      | value                                   | scripts/needles/conversion/2_case/dev/50__Settlements__value.sql                     |
| 50__SpDamages__value.sql                        | SpDamages        | value                                   | scripts/needles/conversion/2_case/dev/50__SpDamages__value.sql                       |
| create__value_indexed.sql                       | create           | value_indexed                           | scripts/needles/discovery/create__value_indexed.sql                                  |
| 01__Defendants__load__party.sql                 |                  |                                         | scripts/needles/conversion/2_case/user_tab/01__Defendants__load__party.sql           |
| 01__Plaintiff__load__party.sql                  |                  |                                         | scripts/needles/conversion/2_case/user_tab/01__Plaintiff__load__party.sql            |
| IndvContacts__load__user_party.sql              |                  |                                         | scripts/needles/conversion/1_contact/user_tab/IndvContacts__load__user_party.sql     |
| Litigation__Deposition__user_tab.sql            |                  |                                         | scripts/needles/conversion/2_case/dev/Litigation__Deposition__user_tab.sql           |
| OrgContacts__load__employer.sql                 |                  |                                         | scripts/needles/conversion/1_contact/user_tab/OrgContacts__load__employer.sql        |
| PlaintiffUDF__user_party__user_tab (2).sql      |                  |                                         | scripts/needles/conversion/2_case/dev/PlaintiffUDF__user_party__user_tab (2).sql     |
| PlaintiffUDF__user_party__user_tab.sql          |                  |                                         | scripts/needles/conversion/2_case/dev/PlaintiffUDF__user_party__user_tab.sql         |
| Referral__LawyerReferral__load.sql              |                  |                                         | scripts/needles/conversion/2_case/dev/Referral__LawyerReferral__load.sql             |
| Referral__OtherReferral__load.sql               |                  |                                         | scripts/needles/conversion/2_case/dev/Referral__OtherReferral__load.sql              |
| Referral__PaidAdvertisement__load.sql           |                  |                                         | scripts/needles/conversion/2_case/dev/Referral__PaidAdvertisement__load.sql          |
| Referral__ReferredOut__load.sql                 |                  |                                         | scripts/needles/conversion/2_case/dev/Referral__ReferredOut__load.sql                |
| sa__create_table__NeedlesUserFields.sql         |                  |                                         | scripts/needles/.dev/sa__create_table__NeedlesUserFields.sql                         |
| udf__IncidentUDF__intake_fields.sql             |                  |                                         | scripts/needles/conversion/4_intake/dev/udf__IncidentUDF__intake_fields.sql          |
| udf__PlaintiffUDF__ds.sql                       |                  |                                         | scripts/needles/conversion/2_case/dev/udf__PlaintiffUDF__ds.sql                      |
| udf__PlaintiffUDF__user_party (2).sql           |                  |                                         | scripts/needles/conversion/2_case/dev/udf__PlaintiffUDF__user_party (2).sql          |
| udf__PlaintiffUDF__user_party.sql               |                  |                                         | scripts/needles/conversion/2_case/dev/udf__PlaintiffUDF__user_party.sql              |