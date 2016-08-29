using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Needletail.DataAccess.Attributes;
using DataAccess.Scaffold.Attributes;

namespace __NAME__.Models
{
    public class UserRole
    {
        
        [Required][TableKey(CanInsertKey = true)]
        public Guid Id { get; set; }
        
        [Required]
        public Guid UserId { get; set; }
        
        [Required]
        public Guid RoleId { get; set; }
        
    }
}
