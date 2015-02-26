Existing results are in ./Results. 
For codes, adjusting of resultfolder is needed.

Algorithms for ICIP14 are in ./JPEG_SR:
a. code: codes for ICIP14; run
	Test_Upfrontal_color_01;
	Test_NonUpfrontal3_4;
	Test_pubfig_color_01;
	Test_JANUS2_LROnly_JPEG;
b. code4denoise: denoise + cvpr13;
	run .\code4denoise\code\code\Test_NonUpfrontal3_1
	input 7 for nonlocal means
	input 8 for TV
	other numbers does not generate good results, ignor them;
c. others: lib tools may be used.

Existing Source data are in ./PIE

Liu07IJCV, run:
Test_Face_JPEG + S3_MainProcedure_Lui07_4_JPEG
Test_Face_Nonupfrontal + S3_MainProcedure_Lui07_Noupfrontal_JPEG

Ma10 code for JPEG, the code is also in .\JPEG_SR\code, run:
PositionPatch_test
PositionPatch_test_pose

Jianchao08, run:
Test_Upfrontal4_1_Compressed_large