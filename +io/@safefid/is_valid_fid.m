function isValid = is_valid_fid(this)

s(1).type = '.';
s(1).subs = 'misc.is_valid_fid';
isValid = subsref(this, s);

end