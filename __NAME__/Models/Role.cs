using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Needletail.DataAccess.Attributes;
using DataAccess.Scaffold.Attributes;

namespace __NAME__.Models
{
    public class Role
    {
        
        [Required][TableKey(CanInsertKey = true)]
        public Guid Id { get; set; }
        
        [MaxLen(50)]
        public string RoleName { get; set; }
        
    }
}
