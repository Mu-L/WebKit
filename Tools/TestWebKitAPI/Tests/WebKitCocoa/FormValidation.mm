/*
 * Copyright (C) 2020 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "config.h"

#import "TestWKWebView.h"
#include "Utilities.h"

TEST(FormValidation, PresentingFormValidationUIWithoutViewControllerDoesNotCrash)
{
    RetainPtr webView = adoptNS([[TestWKWebView alloc] init]);
    [webView synchronouslyLoadHTMLString:@"<!DOCTYPE html>"
        "<form>"
        "    <input required>"
        "    <input type='submit'>"
        "</form>"
        "<script>document.querySelector('input[type=submit]').click()</script>"];
    [webView waitForNextPresentationUpdate];
}

TEST(FormValidation, FormValidationOnUnparentedWindowDoesNotCrash)
{
    RetainPtr configuration = adoptNS([[WKWebViewConfiguration alloc] init]);
    RetainPtr webView = adoptNS([[TestWKWebView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300) configuration:configuration.get() addToWindow:YES]);
    [webView synchronouslyLoadHTMLString:@"<!DOCTYPE html>"
        "<form>"
        "    <input type='email' required>"
        "    <input type='submit'>"
        "</form>"];
    [webView waitForNextPresentationUpdate];
    __block bool ranScript = false;
    [webView evaluateJavaScript:@"document.querySelector('input[type=submit]').click()" completionHandler:^(id result, NSError *error) {
        ranScript = true;
    }];
    TestWebKitAPI::Util::runFor(10_ms);
    // Remove the view from the window before it has a chance to display the form validation bubble.
    [webView removeFromTestWindow];
    TestWebKitAPI::Util::run(&ranScript);
    TestWebKitAPI::Util::runFor(100_ms);
}
