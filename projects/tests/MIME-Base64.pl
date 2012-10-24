use MIME::Base64;

#$encoded = encode_base64('Aladdin:open sesame');

my $q='g4QKTzKXtLIM6wkUk1eBoqnvh2fM61bmWyznZuaHAx0AHWVdUvTNbMvP7UagZgqphpIUfnwYjgXV8vvvx+Z/EgA=';
$decoded = decode_base64($q);

print $decoded;