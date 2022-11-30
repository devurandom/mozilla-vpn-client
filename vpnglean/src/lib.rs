/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

use std::env;

use ffi_support::FfiStr;
use glean::{ClientInfoMetrics, Configuration};

use ffi::helpers::FallibleToString;
use metrics::__generated_pings::register_pings;
use uploader::VPNPingUploader;

// Make internal Glean symbols public for mobile SDK consumption.
pub use glean_core;

mod ffi;
mod metrics;
mod uploader;

const GLEAN_APPLICATION_ID: &str = "mozillavpn";

#[no_mangle]
pub extern "C" fn glean_initialize(is_telemetry_enabled: bool, data_path: FfiStr, channel: FfiStr) {
    let cfg = Configuration {
        data_path: data_path
            .to_string_fallible()
            .expect("Invalid Glean data path.")
            .into(),
        application_id: GLEAN_APPLICATION_ID.into(),
        upload_enabled: is_telemetry_enabled,
        // Default is 500
        max_events: None,
        // Whether Glean should delay persistence of data from metrics with ping lifetime
        delay_ping_lifetime_io: false,
        // Default is "https://incoming.telemetry.mozilla.org"
        server_endpoint: None,
        // Use the Glean provided one once https://bugzilla.mozilla.org/show_bug.cgi?id=1675468 is resolved
        uploader: Some(Box::new(VPNPingUploader::new())),
        // Whether Glean should schedule “metrics” pings for you
        use_core_mps: true,
    };

    let client_info = ClientInfoMetrics {
        app_build: env!("BUILD_ID").to_string(),
        app_display_version: env!("APP_VERSION").to_string(),
        channel: channel.to_string_fallible().ok(),
    };

    register_pings();
    glean::initialize(cfg, client_info);
}

#[no_mangle]
pub extern "C" fn glean_set_upload_enabled(is_telemetry_enabled: bool) {
    glean::set_upload_enabled(is_telemetry_enabled);
}

#[no_mangle]
pub extern "C" fn glean_test_reset_glean(is_telemetry_enabled: bool, data_path: FfiStr) {
    let cfg = Configuration {
        data_path: data_path
            .to_string_fallible()
            .expect("Invalid Glean data path.")
            .into(),
        application_id: GLEAN_APPLICATION_ID.into(),
        upload_enabled: is_telemetry_enabled,
        // Default is 500
        max_events: None,
        // Whether Glean should delay persistence of data from metrics with ping lifetime
        delay_ping_lifetime_io: false,
        // Default is "https://incoming.telemetry.mozilla.org"
        server_endpoint: None,
        // Use the Glean provided one once https://bugzilla.mozilla.org/show_bug.cgi?id=1675468 is resolved
        uploader: Some(Box::new(VPNPingUploader::new())),
        // Whether Glean should schedule “metrics” pings for you
        use_core_mps: true,
    };

    let client_info = ClientInfoMetrics {
        app_build: env!("BUILD_ID").to_string(),
        app_display_version: env!("APP_VERSION").to_string(),
        channel: Some("testing".to_string()),
    };

    glean::test_reset_glean(cfg, client_info, true);
}