common_scalar(A) ::=
		T_LNUMBER
	   |T_DNUMBER
	   |T_CONSTANT_ENCAPSED_STRING
	   |T_LINE
	   |T_FILE
	   |T_CLASS_C
	   |T_METHOD_C
	   |T_FUNC_C(B). {A = B;}