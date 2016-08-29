using System;
using DataAccess.Scaffold.Attributes;
using Needletail.DataAccess.Attributes;

namespace __NAME__.Models
{
    public class EmailMessages
    {
        [Required][TableKey(CanInsertKey = true)]
        public Guid Id { get; set; }

        public int EmailKey { get; set; }

        [MaxLen(50)]
        public string EmailSubject { get; set; }

        [MaxLen(2147483647)]
        public string EmailBody { get; set; }

    }
}
