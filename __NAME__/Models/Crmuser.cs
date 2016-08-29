using System;
using DataAccess.Scaffold.Attributes;
using Needletail.DataAccess.Attributes;

namespace __NAME__.Models
{
    public class Crmuser
    {
        
        [Required][TableKey(CanInsertKey = true)]
        public Guid Id { get; set; }
        
        [Required][MaxLen(50)]
        public string UserName { get; set; }
        
        [Required][MaxLen(50)]
        public string Password { get; set; }

        [Required][MaxLen(50)]
        public string Salt { get; set; }

        [Required][MaxLen(50)]
        public string Name { get; set; }
        
        [Required][MaxLen(150)][Email]
        public string Email { get; set; }
        
    }
}
