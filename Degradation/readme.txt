Matlab software for skeletonization and skeleton pruning

Authors: Xiang Bai and Longin Jan Latecki

Emails: xiang.bai@gmail.com and latecki@temple.edu

This software implements the approach presented in

X. Bai, L. J. Latecki, and W.-Y. Liu: Skeleton Pruning by Contour Partitioning with Discrete Curve Evolution. 
IEEE Trans. Pattern Analysis and Machine Intelligence (PAMI), 29(3), pp. 449-462, 2007.

Please cite this paper when using this software.

For an example on how to run it please see 

Test.m

Important Notices: 
(If you don't read them carefully, your troubles in future have no relation to me:-))  

1. This version can not obtain the pruned skeletons for the test images with holes inside the shapes, since the implentation 
here only can extract the contour of the outlier of the objects.

2. If you want extract the skeletal path from one node to another node, you can use this function: pathDFS1.m.
If your skeletal graph has a loop, you'd better use the shortest path algorithm to replace this function. 
Since this function is using depth-first search algorthm, which can not obtain the shortest path on the skeletons with a loop.
For shape matching (almost shapes are without holes, this function is enough and much faster than the shortest algorithm.

3. For extacting the optimal skeletons, you may need to adjust the stop parameters of DCE for dissimilar shapes.
In another paper of us, "Discrete Skeleton Evolution" (DSE) is more stable than DCE. We have tested it on a large database with 
2000 shapes (the same parameter), and we get very perfect pruned results. I plan to put the code for DSE soon later. 

4.Thank you again for using this software, I hope you can achieve something succussful with it.(I benefit from the pruned skeletons 
a lot often:-))           
 



