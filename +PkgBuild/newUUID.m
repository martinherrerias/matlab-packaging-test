function id = newUUID()
% Return a valid mpm package ID, e.g. 12345678-1234-1234-1234-123456789abc

    tmp = tempname();
    mkdir(tmp);
    pkg = mpmcreate('foo', tmp, Install=false);
    id = pkg.ID;
end