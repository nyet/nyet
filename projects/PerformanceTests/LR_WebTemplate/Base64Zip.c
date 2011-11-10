#include "base64.h"
#include "zlib.h"

Base64Zip()
{
	int dest_size;
	//int res;
	char *dest;
	// CA
	//char *source = "eAF1VMGOEzEM/ZVo7lC4cejuypO4rWniDHFSabitlqqqBK3EFgR/jyuEwOki9VC9+L2xn1+yfPjx5bP7vv/6fDyf7oa3r98Mbn96On86ng53Q6urV++Gh/tleLw8wuFwv3w6fztdjvtn/Xe6/HRKgQgJAwxu8S82EaOFEoRcDDS2Wm2RV7EdFhBT53NsYj/gM9cCzmep9iBgdJxLp6ugflwbMLqrgsIWWkdkNkWblsYcQzUgpQkLQbQgz1Zsi8VqbYnXdrQIW+tABBG0rJjFAa8xouWqoWqVaSFBIUu+IlPu3EvIIXvqZk9YPAarl7WuQ3qWbgILzqaKYbKNMe6gy4juQ4cytCmCR5uRKbbUxaGQRkQoWK6ALxpErnYHAuxGZHoRLgwl9DZcGYFwfauz0o49ib89eZ/hQ+ucv+rERuLySDLdchJUvEEruBGK/qx9qqUnPv4HL+2j8VE20N8LISy9KMmW5twsNUfoNiyZc+r6qcAkEZpNpFwvtN1fxQ105KoZpWoDU5vOZhdam1771L0iO11w6+aYc7Q+zm383e7i72u1+POC/QK902bg";
	char *source = "eAFllEFv2zAMhf+KkPuW7bZD2oKWaVkxJQqUVSO7FV0QBNgcYM2G7d9PGVBsVG/BA2nyfXzR7uHXt6/m5/H7y/my3m0+vv+wMcf1+fLlvJ7uNmUe3n3aPNzv+qfrE5xO97vny4/1ej6+1F/r9bepLdBDyBuz/U8hCJxBawIJRsZGtGMhnHVpB7YRMM6qr+NCPYrWhDkMHqlXsh1hGFCPtSMeMMZGJAQxVhAn/QGOuGdt0HKePZHe0govhAfdXPLc7NkjNX57jI9tERML6qE9F0egNQRH2gZSh6JpIZkEmdVig2DghqoDecvPeUo+ql4nEDVkV2L0mXXZ6GPuoVlvLCgDRL3MHuzUdu+xnk1adfK8aOqTn42FN4UEk+ZCYBJBQ55AfGjQV8QGog8NafLRMmmHxA60ErCJffARBUjxCzwMoE90uwV+LkF7u6nCWRsJLO1UrhnTRLkI6CQmEJ3rNNYE+6TzlPw8NddONdb1EMpBKtiRniieTUdQIanKm/w3L9qEcJk1gQyuQP1jqu4M0exLw/gmBu8KaqoZe7d4q03mEoLXg2Ykak6+QK5hdXMT4KV9Sw6vB9r+ewW3ry/jH9JYf8U=";

	//Byte * zipped = (Byte*)calloc((uInt)1000, 1);
	Byte * unZip = (Byte*)calloc((uInt)1000, 1);
	//unsigned long zipped_len = 1000;
	unsigned long unzipped_len = 2000;
	int rc = 0;
	//int rcReturn = 0;
	//char *encodedParm;
	//char *decodedParm; 

	
	// Allocate dest buffer
	dest_size = strlen(source);
	dest = (char *)malloc(dest_size);
	memset(dest,0,dest_size);
	// Encode & Save
	base64decode(source, dest, dest_size);
	rc = strlen(dest);

	lr_load_dll("zlib1.dll");
	rc = uncompress(unZip, &unzipped_len, (const Bytef*)dest,1315); 
    lr_save_string((char*)unZip, "pCountiesXML"); 

	// Free dest buffer
	free(dest);

	return 0;
}
