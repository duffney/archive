while ($line = <>) {
	if ($line =~ m/Address: ([-a-z0-9]+\.[-a-z0-9]+)*/) {
		$address = $1;
		print "$address \n"
	}
}
