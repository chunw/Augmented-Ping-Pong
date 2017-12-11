#!/bin/bash
for dir in "pingpong_multimode" "pingpong_fireball"

do
  cp pingpong_calibration/Params.pde $dir/Params.pde
  cp pingpong_calibration/Hit.pde $dir/Hit.pde
  cp pingpong_calibration/BallPositionSensor.pde $dir/BallPositionSensor.pde
done
