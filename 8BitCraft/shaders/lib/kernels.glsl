const mat3 sobelX = mat3(
-1.0, 0.0, 1.0,
-2.0, 0.0, 2.0,
-1.0, 0.0, 1.0
);

const mat3 sobelY = mat3(
-1.0, -2.0, -1.0,
0.0, 0.0, 0.0,
1.0, 2.0, 1.0
);

mat3 gaussianKernel(float sigma) {
    float pi = 3.14159;
    float twoSigma2 = 2.0 * sigma * sigma;
    float sigmaRoot = sqrt(twoSigma2 * pi);

    return mat3(
    exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot,
    exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot,
    exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot, exp(-0.5 / twoSigma2) / sigmaRoot
    );
}