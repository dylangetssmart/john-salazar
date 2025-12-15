# Needles Initial Conversion Procedure

## Phase 1 - Data Discovery
1. [Extract data](https://smartadvocate.atlassian.net/wiki/x/QAA2tw)
2. Run scripts in `discovery\`
    - These scripts create helper tables in the Needles database are used during data mapping and conversion.
3. Verify the following tables exist and have records:

```sql
select * from [<client>_Needles]..cases
select * from [<client>_Needles]..party
```

> [!IMPORTANT]
> If these tables are empty, notify the implementation team that the backup is invalid.

## Phase 2 - Data Mapping
1. Create an Excel file, i.e. <Client> Needles Data Mapping.xlsx
2. Run scripts: `mapping\`
    - Keep the results window of each script open.
3. Create a Sheet for each script with a matching name
4. Copy the output of each script into the associated Sheet


## Phase 3 - Data Conversion
### Copy scripts from 📁shared to 📁needles
In the starter kit, `shared\` contains generically applicable scripts that shared across all conversions. Copy relevant scripts from there into the `needles\` directory:
- `shared\00__SA_ClearData_NoAdmin.sql`
- `shared\01__create_functions_and_procedures.sql`
- `shared\07__ContactNumber_Uniqueness.sql`
- `shared\08__AllContactInfo.sql`
- `shared\09__IndvOrgContacts_Indexed.sql`

### Update scripts
Paste values from the mapping spreadsheet into:
- `needles\3_conversion\01__CaseTypeMap.sql`
    - This is not required for the initial conversion. If case types are not mapped, they will simply be created in SmartAdvocate as-is from Needles.
- `needles\3_conversion\01__PartyRoleMap.sql`
- `needles\3_conversion\01__ValueCodeMap.sql`

Customize as per Value Code mapping (remove script if not applicable):
- `needles\3_conversion\value__Disbursements.sql`
- `needles\3_conversion\value__LienTracking.sql`
- `needles\3_conversion\value__MedicalProviders.sql`
- `needles\3_conversion\value__Settlements.sql`
- `needles\3_conversion\value__SpDamages.sql`
- `needles\3_conversion\value__Employment.sql`

### Run scripts
scripts\needles\3_conversion


# Converting Needles user-defined tabs
Needles user-defined tabs use an **[Entity-Attribute-Value](https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)** data model:
- there is one row per **Entity** (case)
- one column per **Attribute**
- and each column holds it's respective **Value**

|entity|attribute|attribute|attribute|
--|--|--|--
|entity_id|value|value|value|
|entity_id|value|value|value|

To complicate things further, it is possible for a user-defined tab to support multiple records per case. In the example below, case `1000` has two sets of Attribute-Value pairs, which are uniquely identified by `tab_id`.

> [!NOTE]
> When there are multiple records per case, a combination of `case_id` + `tab_id` must be used to insert into a UDF Grid instead of a standard UDF page.

**Source data: `[user_tab_data]`**
| case_id | tab_id | Name			| Occupation       |
|---------|--------|----------------|------------------|
| 1000    | 1      | Gordon Freeman | Scientist		   |
| 1000    | 2      | Nathan Drake	| Treasure Hunter  |
| 5000    | 3      | Jack Sparrow	| Pirate		   |
| 5000    | 4      | Frodo Baggins	| Hobbit		   |

To easily insert UDFs, we need to pivot the data to instead be 1 row per Entity (case) per Attribute & Value pair

**Staging table: `##Pivoted_Data`**
| case_id | tab_id | Attribute     | Value             |
|---------|--------|---------------|-------------------|
| 1000    | 1      | Name          | Gordon Freeman	   |
| 1000    | 1      | Occupation	   | Scientist         |
| 1000    | 2      | Name          | Nathan Drake	   |
| 1000    | 2      | Occupation	   | Treasure Hunter   |
| 5000    | 3      | Name          | Jack Sparrow      |
| 5000    | 3      | Occupation    | Pirate            |
| 5000    | 4      | Name          | Frodo Baggins     |
| 5000    | 4      | Occupation    | Hobbit            |
