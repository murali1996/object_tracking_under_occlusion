TRACKING OF MULTI-SKIN COLOURED OBJECTS UNDER OCCLUSION


Skin-colored objects are detected with a Bayesian classifier which is bootstrapped with a small
set of training data. Then, an off-line iterative training procedure is employed to refine the
classifier using additional training images. On-line adaptation of skin-color probabilities is used
to enable the classifier to cope with illumination changes. Tracking over time is realized through
a novel technique which can handle multiple skin-colored objects. Such objects may move in
complex trajectories and occlude each other in the field of view of a possibly moving camera.
Moreover, the number of tracked objects may vary in time. A prototype implementation of the
developed system operates on 720x1080 pixel video with a frame rate of 30 per second.