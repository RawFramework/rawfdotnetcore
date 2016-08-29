using System;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.Security;
using __NAME__.DataAccess.Repositories;
using __NAME__.Models;
using __NAME__.Repositories;
using __NAME__.Utils;

namespace __NAME__.Controllers
{
    [AllowAnonymous]
    public class SignOnController: Controller
    {
        private readonly CrmUserRepository _crmUserRepository;
        private readonly EmailMessagesRepository _emailMessageRepository;
        private readonly EmailOperations _emailOperations;

        public SignOnController()
        {
            _crmUserRepository = new CrmUserRepository();
            _emailOperations = new EmailOperations();
            _emailMessageRepository = new EmailMessagesRepository();
        }


        /// <summary>
        /// Usernames the is available.
        /// </summary>
        /// <param name="userName">Name of the user.</param>
        /// <returns></returns>
        [HttpPost]
        public ActionResult UsernameIsAvailable(string userName)
        {
            var valid = _crmUserRepository.GetSingle(new { UserName = userName }) == null;
            return Json(new { valid = valid });

        }

        /// <summary>
        /// Emails the is available.
        /// </summary>
        /// <param name="email">The email.</param>
        /// <returns></returns>
        [HttpPost]
        public ActionResult EmailIsAvailable(string email)
        {
            var valid = _crmUserRepository.GetSingle(new { Email = email }) == null;
            return Json(new { valid = valid });
        }


        /// <summary>
        /// Logins this instance.
        /// </summary>
        /// <returns></returns>
        public ActionResult Login()
        {
            return View();
        }

        /// <summary>
        /// Logins the specified model.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> Login(LoginViewModel model)
        {
            if (ValidateUserLogin(model))
            {
                FormsAuthentication.SetAuthCookie(model.UserName, model.RememberMe);
                return RedirectToAction("Index", "Home");
            }
            // If we got this far, something failed, redisplay form
            return View(model);
        }

        /// <summary>
        /// Logs the off.
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult LogOff()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Index", "Home");
        }


        /// <summary>
        /// Forgots the password.
        /// </summary>
        /// <returns></returns>
        public ActionResult ForgotPassword()
        {
            return View();
        }

        /// <summary>
        /// Forgots the password.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult ForgotPassword(ForgotPasswordViewModel model)
        {
            var user = _crmUserRepository.GetSingle(new { Email = model.Email });

            if (user == null)
            {
                return new JsonResult { Data = new { error = true, message = "There are no users with the indicated Email" } };
            }

             var encrypt = new Encryption();
            var pass = Guid.NewGuid().ToString().Replace("-", "").Substring(0, 8);
            user.Password = encrypt.Encrypt(pass, user.Salt);
            _crmUserRepository.Update(user);
            _emailOperations.SendResetPasswordNotification(user.Name, model.Email, pass);
            return new JsonResult { Data = new { message = "An Email with you new password has been sent to your email address" } };
        }


        /// <summary>
        /// Validates the user login.
        /// </summary>
        /// <param name="model">The model.</param>
        /// <returns>an indication about if the user is correctly logged in</returns>
        private bool ValidateUserLogin(LoginViewModel model)
        {
            var encryptOperations = new Encryption();
            var userResult = _crmUserRepository.GetSingle(where: new { UserName = model.UserName });
            if (userResult == null)
            {
                return false;
            }

            return userResult.Password == encryptOperations.Encrypt(model.Password, userResult.Salt);
        }

    }
}