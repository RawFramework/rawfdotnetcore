using System;
using System.Collections.Generic;
using System.Linq;
using Needletail.DataAccess.Attributes;
using DataAccess.Scaffold.Attributes;

namespace ConUniv.Models
{
    public class Course
    {
        
        [Required][TableKey(CanInsertKey = true)]
        public Guid Id { get; set; }
        
        [Required][MaxLen(50)]
        public string Title { get; set; }
        
        [Required]
        public int Credits { get; set; }
        
        [Required]
        public Guid DepartmentID { get; set; }
        
    }
}
