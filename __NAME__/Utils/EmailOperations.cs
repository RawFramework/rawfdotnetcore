using System;
using System.Net;
using System.Net.Mail;
using __NAME__.DataAccess.Repositories;

namespace __NAME__.Utils
{
    /// <summary>
    /// Defines the methods used for send email notifications
    /// </summary>
    public class EmailOperations
    {
        enum MessageTypes
        {
            NewAccount = 1,
            ResetsPassword
        }

        readonly EmailMessagesRepository _mailMessagesRepository;

        public EmailOperations()
        {
            _mailMessagesRepository = new EmailMessagesRepository();
        }

        /// <summary>
        /// Sends the new account notification.
        /// </summary>
        /// <param name="name">The name.</param>
        /// <param name="userName">Name of the user.</param>
        /// <param name="email">The email.</param>
        public void SendNewAccountNotification(string name, string userName, string email)
        {
            var message = _mailMessagesRepository.GetSingle( new {EmailKey = Convert.ChangeType(MessageTypes.NewAccount, MessageTypes.NewAccount.GetTypeCode())});
            var bodyMessage = string.Format(message.EmailBody, name, userName);
            SendMailNotification(email, message.EmailSubject, bodyMessage );
        }


        /// <summary>
        /// Sends the new account notification.
        /// </summary>
        /// <param name="name">The name.</param>
        /// <param name="email">The email.</param>
        /// <param name="password">The password.</param>
        public void SendResetPasswordNotification(string name, string email, string password)
        {
            var message = _mailMessagesRepository.GetSingle(new { EmailKey = Convert.ChangeType(MessageTypes.ResetsPassword, MessageTypes.ResetsPassword.GetTypeCode()) });
            var bodyMessage = string.Format(message.EmailBody, name, password);
            SendMailNotification(email, message.EmailSubject, bodyMessage);
        }


        /// <summary>
        /// Sends the mail notification.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <param name="subject">The subject.</param>
        /// <param name="bodyMessage">The body message.</param>
        private void SendMailNotification(string email, string subject, string bodyMessage)
        {
            try
            {
                using (var mail = new MailMessage())
                {
                    mail.From = new MailAddress(ConfigData.EmailFrom);
                    mail.To.Add(email);
                    mail.Subject = subject;
                    mail.Body = bodyMessage;
                    mail.IsBodyHtml = true;
                    using (var smtp = new SmtpClient(ConfigData.SmtpAddress, Convert.ToInt32(ConfigData.SmtpPort)))
                    {
                        smtp.Credentials = new NetworkCredential(ConfigData.EmailFrom, ConfigData.EmailPass);
                        smtp.EnableSsl = true;
                        smtp.Send(mail);
                    }
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}