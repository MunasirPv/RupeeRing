# Privacy Policy

**Effective Date:** 2026-02-28

This privacy policy applies to the **RupeeRing** app (hereby referred to as "Application") for mobile devices that was created by **MunasirPv** as a Free, Open-Source service. This service is intended for use "AS IS".

## 1. Information Collection and Use

The Application is designed as a local UPI payment soundbox and announcement utility. To function properly, it requires specific permissions.

### Notification Access (`BIND_NOTIFICATION_LISTENER_SERVICE`)
The core functionality of the Application relies on intercepting incoming notifications to identify UPI payment alerts securely.
- **What is collected:** The Application processes the content of incoming notifications to extract the payment amount, sender's name, and the specific UPI application (e.g., Google Pay, PhonePe, Paytm).
- **How it is used:** This data is used immediately to announce the payment amount via Text-to-Speech (TTS) and to maintain a local ledger of transactions.
- **Data Sharing and Storage:** **We do not transmit your notifications or any associated data to external servers.** All processing is performed strictly on your local device. 

## 2. Local Data Storage

The Application uses local SQLite databases and shared preferences to log transaction history and user settings. 
- All data remains securely on your device.
- You have full control over this data, and it is permanently deleted when you uninstall the Application or clear its storage.

## 3. Third-Party Services

While the Application does not send your data to external servers, it utilizes your device's built-in Text-to-Speech (TTS) engines to announce payments. 
These built-in features (such as Google TTS on Android) may be governed by their respective providers' privacy policies. No personally identifiable information or full notification content is deliberately shared by the Application with these services beyond what is necessary for speech synthesis.

## 4. Open Source Transparency

The Application is open-source, promoting full transparency regarding its operations. Our source code is available on GitHub, allowing anyone to verify our data handling and privacy practices.
- Repository: [https://github.com/MunasirPv/RupeeRing](https://github.com/MunasirPv/RupeeRing)

## 5. Security

Your privacy and security are our top priority. Because the Application is operated offline-first and stores transactions solely on your device, the risk of data breaches via our Application is virtually eliminated. However, please ensure your device is secured with appropriate screen locks and encryption to protect your local data.

## 6. Children’s Privacy

These Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. 

## 7. Changes to This Privacy Policy

We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted.

## 8. Contact Us

If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact the developer.
- GitHub: [MunasirPv](https://github.com/MunasirPv)
