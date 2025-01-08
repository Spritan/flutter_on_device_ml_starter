//
//  Generated code. Do not modify.
//  source: clip_tf/tokenized_prompts.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use tokenizedPromptsDescriptor instead')
const TokenizedPrompts$json = {
  '1': 'TokenizedPrompts',
  '2': [
    {'1': 'prompts', '3': 1, '4': 3, '5': 11, '6': '.clip_tf.TokenizedPrompt', '10': 'prompts'},
  ],
};

/// Descriptor for `TokenizedPrompts`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenizedPromptsDescriptor = $convert.base64Decode(
    'ChBUb2tlbml6ZWRQcm9tcHRzEjIKB3Byb21wdHMYASADKAsyGC5jbGlwX3RmLlRva2VuaXplZF'
    'Byb21wdFIHcHJvbXB0cw==');

@$core.Deprecated('Use tokenizedPromptDescriptor instead')
const TokenizedPrompt$json = {
  '1': 'TokenizedPrompt',
  '2': [
    {'1': 'input_ids', '3': 1, '4': 3, '5': 3, '10': 'inputIds'},
  ],
};

/// Descriptor for `TokenizedPrompt`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenizedPromptDescriptor = $convert.base64Decode(
    'Cg9Ub2tlbml6ZWRQcm9tcHQSGwoJaW5wdXRfaWRzGAEgAygDUghpbnB1dElkcw==');

