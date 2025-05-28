---

# 🌐 AI-Powered Document Translator 🚀
---

Welcome to the **AI-Powered Document Translator**! This solution leverages the power of Azure AI services to provide seamless and accurate document translation. Simply upload your document, choose your desired language, and download the translated version.

---

## ✨ Features

* **Effortless Document Upload:** Easily upload your documents for translation.
* **Multilingual Support:** Translate documents into a variety of languages.
* **Azure AI Integration:** Powered by Azure Translate for high-quality translations.
* **Automated Workflow:** Built on robust Azure resources (Storage Accounts, Functions) for a smooth, automated process.
* **Infrastructure as Code:** Fully provisioned and managed with Terraform for consistency and scalability.

---

## 🖼️ How It Works

This solution orchestrates a series of Azure services to deliver your translated documents:

1.  **Upload:** You upload your document to a designated Azure Storage Account.
2.  **Trigger:** An Azure Function automatically detects the new document.
3.  **Translate:** The Azure Function utilizes Azure Translate to perform the translation based on your selected language.
4.  **Store:** The translated document is then saved back to an Azure Storage Account.
5.  **Download:** You can then download your translated document from the storage.

---

## 🚀 Getting Started

To use the AI-Powered Document Translator, follow these simple steps:

1.  **Upload Your Document:** Navigate to the designated upload interface (or the Azure Storage Account blob container if direct access is provided) and upload your document.
2.  **Choose Your Language:** Ensure the system is configured for your desired target language. (In a typical web interface, this would be a dropdown selection).
3.  **Download Translation:** Once the translation process is complete (this usually takes a few moments depending on document size), your translated document will be available for download in a specified output location within the Azure Storage Account.

---

## ☁️ Azure Resources

This solution is built upon the following core Azure services:

* **Azure Storage Account:** Used for storing both original and translated documents.
* **Azure Functions:** Serverless compute to orchestrate the translation workflow and interact with Azure Translate.
* **Azure AI (Translator):** The core AI service providing the translation capabilities.

---

## ⚙️ Automation

The entire Azure infrastructure for this solution is provisioned and managed using **Terraform**, ensuring a consistent, repeatable, and scalable deployment.

---

## 🤝 Credit

This solution was proudly built by **ME**.

---
