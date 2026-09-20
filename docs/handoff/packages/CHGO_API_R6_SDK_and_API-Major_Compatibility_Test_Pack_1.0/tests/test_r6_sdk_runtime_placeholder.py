import os, pytest
SDK_ARTIFACT=os.getenv("CHGO_SDK_ARTIFACT","")
pytestmark=pytest.mark.skipif(not SDK_ARTIFACT, reason="Actual SDK/client artifact not supplied")
def test_actual_sdk_artifact_registered():
    assert SDK_ARTIFACT
def test_actual_sdk_major_binding_requires_implementation_specific_adapter():
    pytest.skip("Implement language-specific SDK adapter when actual artifact is supplied")
