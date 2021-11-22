using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Natom.Petshop.Gestion.Entities.DTO.Auth
{
    public class UserDTO
    {
        [JsonProperty("encrypted_id")]
        public string EncryptedId { get; set; }

        [JsonProperty("first_name")]
        public string FirstName { get; set; }

        [JsonProperty("last_name")]
        public string LastName { get; set; }

        [JsonProperty("picture_url")]
        public string PictureURL { get; set; }

        [JsonProperty("email")]
        public string Email { get; set; }

        [JsonProperty("registered_at")]
        public DateTime RegisteredAt { get; set; }
    }
}
