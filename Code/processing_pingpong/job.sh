#!/bin/bash
for dir in "pingpong_multimode" "pingpong_combined_socialmedia" "pingpong_fireball" "pingpong_koi_pond" "pingpong_prey"

do
  cp pingpong_calibration/Params.pde $dir/Params.pde
  cp pingpong_calibration/Hit.pde $dir/Hit.pde
  cp pingpong_calibration/BallPositionSensor.pde $dir/BallPositionSensor.pde
done
