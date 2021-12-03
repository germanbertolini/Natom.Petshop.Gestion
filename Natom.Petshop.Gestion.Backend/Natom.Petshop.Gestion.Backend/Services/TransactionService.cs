using Natom.Petshop.Gestion.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Backend.Services
{
    public class TransactionService
    {
        public Token Token { get; set; }
        public DateTime DateTime { get; set; }

        public TransactionService()
        {
            this.DateTime = DateTime.Now;
        }
    }
}
