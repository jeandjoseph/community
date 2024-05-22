# Incorporating Azure Document Intelligence with Azure AI Search

This project focuses on integrating Azure Document Intelligence with Azure AI Search to structure PDF files and store the structured data in Azure Data Lake Gen2 using Python. The end goal is to generate JSON files for Azure AI Search's Data Source, Indexes, and Indexers, and to query the Azure AI Search Indexes.

## Goals

1. **Structure PDF files** using Azure Document Intelligence.
2. **Store structured data** in Azure Data Lake Gen2 using Python.
3. **Generate 3 JSON files** for Azure AI Search's Data Source, Indexes, and Indexers.
4. **Query** the Azure AI Search Indexes.

## Dependencies

To run this project, you need to install the following libraries:

```bash
pip install azure-ai-formrecognizer==3.3.0
pip install azure-storage-file-datalake
