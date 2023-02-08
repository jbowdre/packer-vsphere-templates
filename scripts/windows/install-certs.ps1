Import-Certificate -FilePath A:\root.cer -CertStoreLocation Cert:\LocalMachine\Root\
Import-Certificate -FilePath A:\ca_1.cer -CertStoreLocation Cert:\LocalMachine\CA\
Import-Certificate -FilePath A:\ca_2.cer -CertStoreLocation Cert:\LocalMachine\CA\
