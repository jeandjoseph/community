# Copilot Studio ALM Architecture (One‑Page Diagram)
```text
                         ┌──────────────────────────────────────────┐
                         │        ENTERPRISE COPILOT STUDIO ALM      │
                         └──────────────────────────────────────────┘

┌───────────────────────────────┐      ┌───────────────────────────────┐
│         DEVELOPMENT            │      │           MONITORING           │
└───────────────────────────────┘      └───────────────────────────────┘

      ┌───────────────────────────────┐       ┌───────────────────────────────┐
      │  Copilot Studio (Maker)       │       │  Power Platform Admin Center   │
      │  - Build agents               │       │  - Audit logs                  │
      │  - Topics, plugins, actions   │       │  - API usage & capacity        │
      │  - RAG sources                │       │  - Environment analytics       │
      └───────────────────────────────┘       └───────────────────────────────┘

      ┌───────────────────────────────┐       ┌───────────────────────────────┐
      │  Power Apps (Solutions)       │       │  Power Apps (Runs & Errors)   │
      │  - Solution packaging         │       │  - Cloud flow run history      │
      │  - Env variables              │       │  - Connection failures         │
      │  - Dataverse tables/flows     │       │  - Solution component health   │
      └───────────────────────────────┘       └───────────────────────────────┘

      ┌───────────────────────────────┐       ┌───────────────────────────────┐
      │  Microsoft Purview            │       │  Microsoft Purview             │
      │  - Classify data sources      │       │  - Data access monitoring       │
      │  - Sensitivity labels         │       │  - DLP alerts                   │
      │  - Access policies            │       │  - Sensitive data movement      │
      └───────────────────────────────┘       └───────────────────────────────┘


┌───────────────────────────────┐      ┌───────────────────────────────┐
│     DEPLOYMENT PIPELINE       │      │           GOVERNANCE           │
└───────────────────────────────┘      └───────────────────────────────┘

      ┌───────────────────────────────┐       ┌───────────────────────────────┐
      │  Power Platform Pipelines     │       │  Power Platform Admin Center   │
      │  - Dev → Test → Prod          │       │  - DLP policies                │
      │  - Managed solutions          │       │  - Environment roles            │
      │  - Connection mapping         │       │  - Managed Environments         │
      │  - Approvals & logs           │       │  - Security & access control    │
      └───────────────────────────────┘       └───────────────────────────────┘

      ┌───────────────────────────────┐       ┌───────────────────────────────┐
      │  Power Apps (Solution Mgmt)   │       │  Microsoft Purview             │
      │  - Versioning                 │       │  - Sensitivity enforcement      │
      │  - Dependencies               │       │  - Zero Trust boundaries        │
      │  - Env variable values        │       │  - DSPM for RAG sources         │
      └───────────────────────────────┘       └───────────────────────────────┘
```

