Fix bootkube-start to move the manifests from all directories. Otherwise the
-d check will fail when /opt/bootkube/assets/manifests-* expands to multiple
directories.

```diff
--- bootkube-start.20171206-uplex-lf	2017-12-06 21:56:50.000000000 +0000
+++ bootkube-start	2017-12-06 22:08:04.000000000 +0000
@@ -2,7 +2,7 @@
 # Wrapper for bootkube start
 set -e
 # Move experimental manifests
-[ -d /opt/bootkube/assets/manifests-* ] && mv /opt/bootkube/assets/manifests-*/* /opt/bootkube/assets/manifests && rm -rf /opt/bootkube/assets/manifests-*
+[ -n "$(find /opt/bootkube/assets/manifests-* -maxdepth 0 -type d -print 2>/dev/null)" ] && mv /opt/bootkube/assets/manifests-*/* /opt/bootkube/assets/manifests && rm -rf /opt/bootkube/assets/manifests-*
 [ -d /opt/bootkube/assets/experimental/manifests ] && mv /opt/bootkube/assets/experimental/manifests/* /opt/bootkube/assets/manifests && rm -r /opt/bootkube/assets/experimental/manifests
 [ -d /opt/bootkube/assets/experimental/bootstrap-manifests ] && mv /opt/bootkube/assets/experimental/bootstrap-manifests/* /opt/bootkube/assets/bootstrap-manifests && rm -r /opt/bootkube/assets/experimental/bootstrap-manifests
 BOOTKUBE_ACI="${BOOTKUBE_ACI:-quay.io/coreos/bootkube}"
```
