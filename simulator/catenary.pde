/**
 * given two points a = [ax, ay] and b = [bx, by] in the vertical plane,
 * rope length rLength, and the number of intermediate points N,
 * outputs the coordinates X and Y of the hanging rope from a to b
 * the optional input sagInit initializes the sag parameter for the
 * root-finding procedure.
 *
 * Ported from MATLAB code written by Yuval:
 * https://www.mathworks.com/matlabcentral/fileexchange/38550-catenary-hanging-rope-between-two-points
 */
float[][] catenary (float[] a, float[] b, float rLength, int N, float sagInit) {
  int maxIter    = 100;     // maximum number of iterations
  float minGrad  = 1e-10;   // minimum norm of gradient
  float minVal   = 1e-8;    // minimum norm of sag function
  float stepDec  = 0.5;     // factor for decreasing stepsize
  float minStep  = 1e-9;    // minimum step size
  float minHoriz = 1e-3;    // minumum horizontal distance
  float sag = sagInit;
  float[] X = new float[N];
  float[] Y = new float[N];
  int i;
  float[][] coords = new float[N][2];
  
  if (a[0] > b[0]) {
    float[] tmp = b;
    b = a;
    a = tmp;
  }
  
  float d = b[0] - a[0];
  float h = b[1] - a[1];
  
  if (abs(d) < minHoriz) {
    // almost perfectly vertical
    for (i = 0; i < N; i++) {
      X[i] = (a[0] + b[0]) / 2;
    }

    if (rLength < abs(h)) {
      // rope is stretched
      Y = linspace(a[1], b[1], N);
    } else {
      sag = (rLength - abs(h)) / 2;
      int nSag = ceil(N * sag / rLength);
      float yMax = max(a[1], b[1]);
      float yMin = min(a[1], b[1]);
      Y = concat(
        linspace(yMax, yMin - sag, N - nSag),
        linspace(yMin - sag, yMin, nSag)
      );
    }

    return zip(X, Y);
  }
  
  X = linspace(a[0], b[0], N);
  
  if (rLength <= sqrt(pow(d, 2) + pow(h, 2))) {
    // rope is stretched: straight line
    Y = linspace(a[1], b[1], N);
  } else {
    // find rope sag
    for (int iter = 0; iter < maxIter; iter++) {
      float val = g(sag, d, h, rLength);
      float grad = dg(sag, d);
      
      if (abs(val) < minVal || abs(grad) < minGrad) {
        break;
      }
      
      float search = -g(sag, d, h, rLength) / dg(sag, d);
      float alpha = 1;
      float sagNew = sag + alpha * search;
      
      while (sagNew < 0 || abs(g(sagNew, d, h, rLength)) > abs(val)) {
        alpha = stepDec * alpha;
        if (alpha < minStep) {
          break;
        }
        
        sagNew = sag + alpha * search;      
      }
      
      sag = sagNew;
    }
  
    // get location of rope minimum and vertical bias
    float xLeft = 0.5 * (log((rLength + h) / (rLength - h)) / sag - d);
    float xMin = a[0] - xLeft;
    float bias = (float)(a[1] - Math.cosh(xLeft * sag) / sag);

    for (i = 0; i < Y.length; i++) {
      Y[i] = (float)(Math.cosh((X[i] - xMin) * sag) / sag + bias);
    }
  }

  return zip(X, Y);
}

float[][] catenary (float[] a, float[] b, float rLength, int N) {
  return catenary(a, b, rLength, N, 1);
}


/********************************************************************************
 * Helper methods
 ********************************************************************************/
 
/**
 * Mocks the MATLAB `linspace` method:
 *   https://www.mathworks.com/help/matlab/ref/linspace.html#bufmmx4
 *
 * Generates a linearly spaced vector of `n` points in the interval[`x1`, `x2`] 
 */
float[] linspace (float x1, float x2, int n) {
  float[] vector = new float[n];
  vector[0] = x1;
  vector[n - 1] = x2;
  
  float spacingInterval = (x2 - x1) / (n - 1);
  for (int i = 1; i < n; i++) {
    vector[i] = x1 + spacingInterval * i;
  }
  
  return vector;
}

/**
 * Takes two arrays of floats and zips them together. For example:
 *
 *   zip([ 1, 2, 3 ], [ 4, 5, 6 ]) -> [[ 1, 4 ], [ 2, 5 ], [ 3, 6 ]]
 */
float[][] zip (float[] X, float[] Y) {
  float[][] coords = new float[X.length][2];
  for (int i = 0; i < X.length; i++) {
    float[] coord = new float[2];
    coord[0] = X[i];
    coord[1] = Y[i];
    coords[i] = coord;
  }
  return coords;
}

/**
 * Not exactly sure what these two methods do...
 */
float g (float s, float d, float h, float rLength) {
  return (float)(2 * Math.sinh(s * d / 2) / s - sqrt(pow(rLength, 2) - pow(h, 2)));
}

float dg (float s, float d) {
  return (float)(2 * Math.cosh(s * d / 2) * d / (2 * s) - (2 * Math.sinh(s * d / 2) / pow(s, 2)));
}