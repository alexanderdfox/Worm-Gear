// ====================================================================
// PARAMETRIC TORUS WORM GEAR GENERATOR
// ====================================================================

/* [Torus Dimensions] */
// Major radius of the torus (distance from center to middle of tube)
major_radius = 30; // [30:500]
// Minor radius of the torus (radius of the tube itself)
minor_radius = 5;  // [5:150]

/* [Thread Parameters] */
// Number of independent thread starts wrapping around the torus
starts = 5;         // [1:24]
// Thread depth multiplier relative to minor radius
depth_ratio = 0.4;  // [0.1:0.05:1.2]
// Total twist/wrapping frequency around the torus ring
twist_ratio = 10;   // [5:1:150]

/* [Resolution] */
// Smoothness around the major torus circle
ring_segments = 300; // [20:300]
// Smoothness of the outer thread profile circle
profile_segments = 100; // [8:100]


// ====================================================================
// MAIN EXECUTION
// ====================================================================

torus_worm_gear(
    R = major_radius, 
    r = minor_radius, 
    n = starts, 
    d = depth_ratio, 
    twists = twist_ratio, 
    segs = ring_segments, 
    p_segs = profile_segments
);

// ====================================================================
// MODULES & GEOMETRY GENERATION
// ====================================================================

module torus_worm_gear(R, r, n, d, twists, segs, p_segs) {
    // We generate the torus by sweeping and uniting overlapping slices 
    // rotated incrementally around the Z-axis.
    union() {
        for (i = [0 : segs - 1]) {
            // Current sweep angle around the torus major axis
            let (angle = i * (360 / segs)) {
                rotate([0, 0, angle])
                translate([R, 0, 0])
                rotate([90, 0, 0]) // Align 2D slices to face along the circular sweep path
                
                // Construct a 2D slice that has teeth modulated by the twist angle
                linear_extrude(height = (2 * PI * R / segs) * 1.05, center = true, convexity = 10)
                modulated_profile(r = r, n = n, d = d, phase = angle * twists, p_segs = p_segs);
            }
        }
    }
}

// Generates the 2D circular profile with sinusoidal/trapezoidal gear teeth modulated by pitch phase
module modulated_profile(r, n, d, phase, p_segs) {
    polygon(
        points = [
            for (j = [0 : p_segs - 1]) 
                let (
                    u_angle = j * (360 / p_segs),
                    // Modulate the radius using sine waves adjusted by the twist phase
                    tooth_height = sin(u_angle * n - phase),
                    // Constrain the tooth shape to have flatter peaks/valleys
                    clamped_height = max(-0.6, min(0.6, tooth_height * 2)),
                    current_r = r + (clamped_height * (r * d))
                )
                [current_r * cos(u_angle), current_r * sin(u_angle)]
        ]
    );
}