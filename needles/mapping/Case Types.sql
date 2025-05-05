SELECT
    m.matcode AS case_type,
    m.header,
    m.description,
    m.active,
    c.[count] as case_count,
    CASE WHEN show_value_tab = 'Y' THEN m.value_tab_title ELSE 'N/A' END AS Value_Tab,
    CASE WHEN show_insurance_tab = 'Y' THEN m.insurance_tab_title ELSE 'N/A' END AS Insurance_Tab,
    CASE WHEN show_negotiation_tab = 'Y' THEN m.negotiation_tab_title ELSE 'N/A' END AS Negotiation_Tab,
    CASE WHEN show_counsel_tab = 'Y' THEN m.counsel_tab_title ELSE 'N/A' END AS Counsel_Tab,
    CASE WHEN show_police_tab = 'Y' THEN m.police_tab_title ELSE 'N/A' END AS Police_Tab,
    CASE WHEN show_document_tab = 'Y' THEN m.documents_tab_title ELSE 'N/A' END AS Documents_Tab,
    CASE WHEN show_status_tab = 'Y' THEN m.status_title ELSE 'N/A' END AS Status_Tab,
    CASE WHEN show_crm_tab = 'Y' THEN m.crm_title ELSE 'N/A' END AS CRM_Tab,
    CASE WHEN show_time_tab = 'Y' then m.time_tab_title ELSE 'N/A' END AS Time_Tab,
	CASE WHEN show_user_tab = 'Y' THEN tab_title ELSE 'N/A' END AS user_tab_1,
    CASE WHEN show_user_tab2 = 'Y' THEN tab2_title ELSE 'N/A' END AS user_tab_2,
    CASE WHEN show_user_tab3 = 'Y' THEN tab3_title  ELSE 'N/A' END AS user_tab_3,
    CASE WHEN show_user_tab4 = 'Y' THEN tab4_title  ELSE 'N/A' END AS user_tab_4,
    CASE WHEN show_user_tab5 = 'Y' THEN tab5_title  ELSE 'N/A' END AS user_tab_5,
    CASE WHEN show_user_tab6 = 'Y' THEN tab6_title  ELSE 'N/A' END AS user_tab_6,
    CASE WHEN show_user_tab7 = 'Y' THEN tab7_title  ELSE 'N/A' END AS user_tab_7,
    CASE WHEN show_user_tab8 = 'Y' THEN tab8_title  ELSE 'N/A' END AS user_tab_8,
    CASE WHEN show_user_tab9 = 'Y' THEN tab9_title  ELSE 'N/A' END AS user_tab_9,
    CASE WHEN show_user_tab10 = 'Y' THEN tab10_title else 'N/A' END AS user_tab_10
FROM [Needles]..matter m
INNER JOIN (
    SELECT
        ci.matcode,
        COUNT(*) AS [count]
    FROM [Needles]..cases_indexed ci
    GROUP BY ci.matcode
) c
    ON m.matcode = c.matcode
ORDER BY m.matcode;