# Needles Mapping

| Script Name | Description | Dependencies |
|-------------|-------------|-------------|
| Case Staff.sql | Outputs distinct case staff | [None] |
| Case Types.sql | Outputs matter codes and the number of times each is used. | [None] |
| Intake.sql | Outputs fields from [user_case_intake_matter] | [None] |
| Party Roles.sql | Outputs party roles and the number of times each is used. | [None] |
| User Tabs.sql | Outputs CustomFieldUsage with CustomFieldSampleData | [None] |
| Value Codes.sql | Outputs entire value_code table | [None] |
| _create_CustomFieldUsage.sql | Creates table [CustomFieldUsage] and seeds it with all fields from the needles user tabs. Includes sample data. | [None] |
| _create_CustomFieldUsage_intake.sql | Outputs fields from [user_case_intake_matter] | [None] |
