use HTML::Entities;

my $q='g4QKTzKXtLIM6wkUk1eBoqnvh2fM61bmWyznZuaHAx0AHWVdUvTNbMvP7UagZgqphpIUfnwYjgXV8vvvx+Z/EgA=';
#my $q='g4QKTzKXtLIM6wkUk1eBoqnvh2fM61bmWyznZuaHAx0AHWVdUvTNbMvP7UagZgqphpIUfnwYjgXV8vvvx%2bZ%2fEgA%3d';

print decode_entities($q);
