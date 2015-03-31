#!/bin/bash

OUTPUT_FILE="/var/www/html/status.html"
MDADM=$(mdadm --detail /dev/md0)


cat > $OUTPUT_FILE <<- EOF
<html>
<head>
	<title>Server Status</title>
</head>
<body>

<h1>mdadm</h1>
<hr/>
<pre>$MDADM</pre>

</body>
</html>
EOF

