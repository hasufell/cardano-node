{-# LANGUAGE OverloadedStrings #-}

module Test.CLI.Shelley.Golden.TextEnvelope.Keys.VRFKeys
  ( golden_shelleyVRFKeys
  ) where

import           Cardano.Api.Typed (AsType (..), HasTextEnvelope (..))
import           Cardano.Prelude
import           Hedgehog (Property)
import           Test.OptParse

-- | 1. Generate a key pair
--   2. Check for the existence of the key pair
--   3. Check the TextEnvelope serialization format has not changed.
golden_shelleyVRFKeys :: Property
golden_shelleyVRFKeys = propertyOnce . moduleWorkspace "tmp" $ \tempDir -> do
  -- Reference keys
  referenceVerKey <- noteInputFile "test/Test/golden/shelley/keys/vrf_keys/verification_key"
  referenceSignKey <- noteInputFile "test/Test/golden/shelley/keys/vrf_keys/signing_key"

  -- Key filepaths
  verKey <- noteTempFile tempDir "vrf-verification-key-file"
  signKey <- noteTempFile tempDir "vrf-signing-key-file"

  -- Generate vrf verification key
  void $ execCardanoCLI
    [ "shelley","node","key-gen-VRF"
    , "--verification-key-file", verKey
    , "--signing-key-file", signKey
    ]

  let signingKeyType = textEnvelopeType (AsSigningKey AsVrfKey)
      verificationKeyType = textEnvelopeType (AsVerificationKey AsVrfKey)

  -- Check the newly created files have not deviated from the
  -- golden files
  checkTextEnvelopeFormat verificationKeyType referenceVerKey verKey
  checkTextEnvelopeFormat signingKeyType referenceSignKey signKey
