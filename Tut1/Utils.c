//
//  Utils.c
//  Tut1
//
//  Created by Evgenij on 5/1/13.
//  Copyright (c) 2013 Evgenij. All rights reserved.
//

#include "Utils.h"
#include <math.h>

float gaussian(float x, float deviation)
{
    return (1.0 / sqrt(TWOPI * deviation)) * exp(-((x * x) / (2.0 * deviation)));
}
