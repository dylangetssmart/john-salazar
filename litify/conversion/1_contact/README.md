# Litify Conversion 1_Contact

| Script Name | Description | Dependencies |
|-------------|-------------|-------------|
| 1.00_std_ind_common.sql | Handles common operations related to [sma_MST_IndvContacts] | [None] |
| 1.01_std_ind_user.sql | No metadata found | No metadata found |
| 1.02_std_users.sql | No metadata found | No metadata found |
| 1.03_std_ind_account.sql | No metadata found | No metadata found |
| 1.04_std_ind_contact.sql | No metadata found | No metadata found |
| 1.05_std_ind_lawFirm.sql | No metadata found | No metadata found |
| 1.10_std_org_common.sql | No metadata found | No metadata found |
| 1.11_std_org_account.sql | No metadata found | No metadata found |
| 1.12_std_org_lawFirm.sql | No metadata found | No metadata found |
| 1.13_std_org_referralSource.sql | No metadata found | No metadata found |
| 1.60_std_email.sql | Email addresses | [None] |
| 1.70_std_address_common.sql | No metadata found | No metadata found |
| 1.71_std_address_ind.sql | No metadata found | No metadata found |
| 1.72_std_address_org.sql | No metadata found | No metadata found |
| 1.79_std_address_appendix.sql | No metadata found | No metadata found |
| 1.80_std_phone_common.sql | Handles common operations related to [sma_MST_IndvContacts] | [None] |
| 1.81_std_phone_ind.sql | Phone numbers for individual contacts | [None] |
| 1.82_std_phone_org.sql | Phone numbers for individual contacts | [None] |
| 1.90_std_uniqueness.sql | No metadata found | No metadata found |
| 1.91_std_AllContactInfo.sql | Create sma_MST_AllContactInfo | [['sma_MST_AllContactInfo'], ['sma_MST_IndvContacts'], ['sma_MST_Address'], ['sma_MST_ContactNumbers'], ['sma_MST_EmailWebsite']] |
| 1.92_std_IndvOrgContacts_Indexed.sql | None | ['sma_MST_AllContactInfo'] |
| 1.93_RelContacts.sql | No metadata found | No metadata found |
| 1.99_CreateView_LitifyRoleMap.sql | No metadata found | No metadata found |
| 1.xx_skip_Contacts.sql | No metadata found | No metadata found |
| 1.xx_skip_Email_Phone.sql | No metadata found | No metadata found |
| 1.xx_skip_std_address.sql | No metadata found | No metadata found |
