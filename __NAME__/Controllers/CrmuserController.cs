using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Configuration;
using System.Threading.Tasks;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using System.Web.Security;
using Microsoft.Owin.Security.Provider;
using Needletail.DataAccess.Engines;
using __NAME__.DataAccess.Repositories;
using __NAME__.Models;
using __NAME__.Repositories;
using __NAME__.Utils;

namespace __NAME__.Controllers
{
    [Authorize]
    //Basic Controller template, avoid adding bussiness logic code here, use the Repository instead
    public class CrmUserController : Controller
    {
        public Dictionary<string, Func<Crmuser, IComparable>> DynamicOrdering = new Dictionary<string, Func<Crmuser, IComparable>>
        {
            {"Id",opt => opt.Id},
            {"UserName",opt => opt.UserName},
            {"Password",opt => opt.Password},
            {"Salt",opt => opt.Salt},
            {"Name",opt => opt.Name},
            {"Email",opt => opt.Email}
        };


        readonly CrmUserRepository crmuserRepository;
        readonly EmailOperations mailOperations;

        public CrmUserController() {

            //Remove this line if you want to use dependency injection 
            
            crmuserRepository = new CrmUserRepository();
            mailOperations = new EmailOperations();
        }

        //
        // GET: /Crmuser/

        public ActionResult Index()
        {
            return View();
        }

        //
        // GET: /Crmuser/Details/id

        public ActionResult Details(Guid id)
        {
            ViewBag.id = id;
            return View();
        }

        //
        // GET: /Crmuser/Create
        [AllowAnonymous]
        public ActionResult Create()
        {
            var Crmuser = new Crmuser();
            ViewBag.Crmuser = new JavaScriptSerializer().Serialize(Crmuser);
            return View();
        }

        //
        // POST: /Crmuser/Create

        [HttpPost]
        [AllowAnonymous]
        public ActionResult Create(Crmuser model)
        {
            var encrypt = new Encryption();
            model.Id = Guid.NewGuid();
            model.Password = encrypt.Encrypt(model.Password, model.Salt);
            crmuserRepository.Insert(model);
            mailOperations.SendNewAccountNotification(model.Name, model.UserName, model.Email);
            return Json(new { result = "Redirect", url = Url.Action("Login", "SignOn") });
        }

        //
        // GET: /Crmuser/Edit/id

        public ActionResult Edit(Guid id)
        {
            ViewBag.id = id;
            return View();
        }

        //
        // POST: /Crmuser/Edit/id

        [HttpPost]
        public ActionResult Edit(Crmuser model)
        {
            var result = crmuserRepository.UpdateWithWhere(values: model,
                            where: new {Id = model.Id});

            return Json(new { result = "Redirect", url = Url.Action("Index", "Crmuser") });
        }

        //
        // POST: /Crmuser/Delete/5

        [HttpPost, ActionName("Delete")]
        public bool Delete(Guid id)
        {
            var result = crmuserRepository.Delete(where: new {Id = id});
            return result;
        }

        #region crmuser data access

        [HttpPost]
        public JsonResult GetCrmusers()
        {
            var crmusers = crmuserRepository.GetAll();

            var result = new {
                crmusers = crmusers
            };

            return Json(result);
        }

        [HttpPost]
        [AllowAnonymous]
        public JsonResult GetCrmuser(Guid id)
        {
            
        var crmuser = crmuserRepository.GetSingle(where: new {Id = id});
        crmuser = crmuser ?? new Crmuser();
            

            var result = new
            {
                crmuser = crmuser
            };

            return Json(result);
        }

        [HttpPost]
        public JsonResult GetAllCrmuser(int page_num, int rows_per_page)
        {
            var list = new List<dynamic>();
            var sortField = this.Request.Form["sorting[0][field]"];
            var sort = this.Request.Form["sorting[0][order]"];
            
            var totalRows = crmuserRepository.ExecuteScalar<int>("SELECT Count(Id) FROM crmuser", new Dictionary<string, object>());
            var registers = crmuserRepository.GetMany(
                new {},
                new {},
                FilterType.AND,
                page_num - 1,
                rows_per_page
            );

            registers = (sort == "descending") ?
                registers.OrderByDescending(DynamicOrdering[sortField]) :
                registers.OrderBy(DynamicOrdering[sortField]);

            foreach (var row in registers)
            {
                var objId = row.Id.ToString();
                list.Add(new
                {   
                    Id = row.Id,
                    UserName = row.UserName,
                    Password = row.Password,
                    Salt = row.Salt,
                    Name = row.Name,
                    Email = row.Email,
                    edit = string.Format("<a href = \"/crmuser/edit/{0}\">Edit</a>", objId),
                    details = string.Format("<a href = \"/crmuser/Details/{0}\">Details</a>", objId),
                    delete = string.Format("<a href = \"/crmuser/delete/{0}\">Delete</a>", objId)
                });
            }
 
            return Json(new { total_rows = totalRows, page_data = list });;
        }

        #endregion

    }
}
