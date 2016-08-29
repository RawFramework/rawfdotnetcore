using __NAME__.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace __NAME__.Utils
{
    public static class UserIdentityExtensions
    {
        private static CrmUserRepository allUsers = new CrmUserRepository();
        public static Guid GetUserId(this System.Security.Principal.IIdentity identity)
        {
            var usr = allUsers.GetSingle(where: new { UserName = identity.Name });
            return usr!= null? usr.Id : Guid.Empty;
        }
    }
}