       ... 3 more
Caused by: java.lang.Exception: Could not close incremental caches in D:\Education\PRM393\QuizAppTravel\build\google_sign_in_android\kotlin\compileDebugKotlin\cacheable\caches-jvm\jvm\kotlin: class-fq-name-to-source.tab, source-to-classes.tab, internal-name-to-source.tab
	at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:95)
	at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.close(BasicMapsOwner.kt:53)
	at org.jetbrains.kotlin.com.google.common.io.Closer.close(Closer.java:205)
	... 22 more
	Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
		at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
		at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
		at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.save(FileToPathConverter.kt:33)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.save(FileToPathConverter.kt:30)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:447)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
		at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
		at org.jetbrains.kotlin.incremental.storage.PersistentStorageWrapper.close(PersistentStorage.kt:124)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
		... 24 more
	Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
		at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
		at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
		at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:50)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:30)
		at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.hashKey(LinkedCustomHashMap.java:109)
		at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.remove(LinkedCustomHashMap.java:153)
		at org.jetbrains.kotlin.com.intellij.util.containers.SLRUMap.remove(SLRUMap.java:89)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.flushAppendCache(PersistentMapImpl.java:1007)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:455)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
		at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
		at org.jetbrains.kotlin.incremental.storage.AppendableInMemoryStorage.applyChanges(InMemoryStorage.kt:179)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
		at org.jetbrains.kotlin.incremental.storage.AppendableSetBasicMap.close(BasicMap.kt:157)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
		... 24 more
	Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
		at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
		at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
		at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.save(FileToPathConverter.kt:33)
		at org.jetbrains.kotlin.incremental.storage.FileDescriptor.save(FileToPathConverter.kt:30)
		at org.jetbrains.kotlin.incremental.storage.AppendableCollectionExternalizer.save(LazyStorage.kt:151)
		at org.jetbrains.kotlin.incremental.storage.AppendableCollectionExternalizer.save(LazyStorage.kt:142)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:447)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
		at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
		at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
		at org.jetbrains.kotlin.incremental.storage.AppendableInMemoryStorage.applyChanges(InMemoryStorage.kt:179)
		at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
		at org.jetbrains.kotlin.incremental.storage.PersistentStorageWrapper.close(PersistentStorage.kt:124)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
		... 24 more
	Suppressed: java.lang.Exception: Could not close incremental caches in D:\Education\PRM393\QuizAppTravel\build\google_sign_in_android\kotlin\compileDebugKotlin\cacheable\caches-jvm\lookups: id-to-file.tab, file-to-id.tab
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:95)
		at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.close(BasicMapsOwner.kt:53)
		at org.jetbrains.kotlin.incremental.LookupStorage.close(LookupStorage.kt:155)
		... 23 more
		Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
			at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
			at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
			at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
			at org.jetbrains.kotlin.incremental.storage.LegacyFileExternalizer.save(IdToFileMap.kt:51)
			at org.jetbrains.kotlin.incremental.storage.LegacyFileExternalizer.save(IdToFileMap.kt:48)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:447)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
			at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
			at org.jetbrains.kotlin.incremental.storage.PersistentStorageWrapper.close(PersistentStorage.kt:124)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
			... 25 more
		Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
			at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
			at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
			at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
			at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:50)
			at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:30)
			at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.hashKey(LinkedCustomHashMap.java:109)
			at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.remove(LinkedCustomHashMap.java:153)
			at org.jetbrains.kotlin.com.intellij.util.containers.SLRUMap.remove(SLRUMap.java:89)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.flushAppendCache(PersistentMapImpl.java:1007)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:455)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
			at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
			at org.jetbrains.kotlin.incremental.storage.PersistentStorageWrapper.close(PersistentStorage.kt:124)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
			... 25 more
	Suppressed: java.lang.Exception: Could not close incremental caches in D:\Education\PRM393\QuizAppTravel\build\google_sign_in_android\kotlin\compileDebugKotlin\cacheable\caches-jvm\inputs: source-to-output.tab
		... 25 more
		Suppressed: java.lang.IllegalArgumentException: this and base files have different roots: C:\Users\123bi\AppData\Local\Pub\Cache\hosted\pub.dev\google_sign_in_android-7.2.11\android\src\main\kotlin\io\flutter\plugins\googlesignin\Messages.kt and D:\Education\PRM393\QuizAppTravel\android.
			at kotlin.io.FilesKt__UtilsKt.toRelativeString(Utils.kt:117)
			at kotlin.io.FilesKt__UtilsKt.relativeTo(Utils.kt:128)
			at org.jetbrains.kotlin.incremental.storage.RelocatableFileToPathConverter.toPath(RelocatableFileToPathConverter.kt:24)
			at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:50)
			at org.jetbrains.kotlin.incremental.storage.FileDescriptor.getHashCode(FileToPathConverter.kt:30)
			at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.hashKey(LinkedCustomHashMap.java:109)
			at org.jetbrains.kotlin.com.intellij.util.containers.LinkedCustomHashMap.remove(LinkedCustomHashMap.java:153)
			at org.jetbrains.kotlin.com.intellij.util.containers.SLRUMap.remove(SLRUMap.java:89)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.flushAppendCache(PersistentMapImpl.java:1007)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.doPut(PersistentMapImpl.java:455)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentMapImpl.put(PersistentMapImpl.java:426)
			at org.jetbrains.kotlin.com.intellij.util.io.PersistentHashMap.put(PersistentHashMap.java:106)
			at org.jetbrains.kotlin.incremental.storage.LazyStorage.set(LazyStorage.kt:80)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.applyChanges(InMemoryStorage.kt:108)
			at org.jetbrains.kotlin.incremental.storage.AppendableInMemoryStorage.applyChanges(InMemoryStorage.kt:179)
			at org.jetbrains.kotlin.incremental.storage.InMemoryStorage.close(InMemoryStorage.kt:136)
			at org.jetbrains.kotlin.incremental.storage.AppendableSetBasicMap.close(BasicMap.kt:157)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner$close$1.invoke(BasicMapsOwner.kt:53)
			at org.jetbrains.kotlin.incremental.storage.BasicMapsOwner.forEachMapSafe(BasicMapsOwner.kt:87)
			... 24 more

Running Gradle task 'assembleDebug'...                             69.5s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...           4.9s
D/FlutterJNI(13114): Beginning load of flutter...
D/FlutterJNI(13114): flutter (null) was loaded normally!
I/flutter (13114): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
I/flutter (13114): [IMPORTANT:flutter/shell/platform/android/android_context_gl_impeller.cc(104)] Using the Impeller rendering backend (OpenGLES).
D/FlutterRenderer(13114): Width is zero. 0,0
D/FlutterRenderer(13114): Width is zero. 0,0
D/FlutterJNI(13114): Sending viewport metrics to the engine.
I/SurfaceView(13114): 131146089 surfaceChanged -- format=4 w=1080 h=2352
D/BufferQueueProducer(13114): [SurfaceView[com.example.quiz_app_travel/com.example.quiz_app_travel.MainActivity]#1(BLAST Consumer)1](id:333a00000001,api:1,p:13114,c:13114) disconnect: api 1
D/BufferQueueProducer(13114): [SurfaceView[com.example.quiz_app_travel/com.example.quiz_app_travel.MainActivity]#1(BLAST Consumer)1](id:333a00000001,api:1,p:13114,c:13114) connect: api=1 producerControlledByApp=true
D/ViewRootImplExtImpl(13114): setMaxDequeuedBufferCount: 2
I/DynamicFramerate [FRTCConfigManager](13114): initFrameRateConfig:
I/DynamicFramerate [FRTCConfigManager](13114): 	levels: [120, 60, 40, 30]
I/DynamicFramerate [FRTCConfigManager](13114): 	thresholds: [400, 80, 30]
I/DynamicFramerate [FRTCConfigManager](13114): 	scrollbar fade frame rate: 0
I/DynamicFramerate [FRTCConfigManager](13114): FRTCConfigManager: FRTC_CAPABILITY = 120, package name = com.example.quiz_app_travel, PACKAGE_ENABLE = false
I/DynamicFramerate [DynamicFrameRateController](13114): init info: mPackageName = com.example.quiz_app_travel, mIsEnabled = false
I/Quality (13114): ActivityThread: doFrame delay 634 com.example.quiz_app_travel 13114
I/Choreographer(13114): Skipped 73 frames!  The application may be doing too much work on its main thread.
I/Quality (13114): Skipped: false 73 cost 616.974 refreshRate 8348911 bit true processName com.example.quiz_app_travel
D/FlutterJNI(13114): Sending viewport metrics to the engine.
I/Quality (13114): Skipped: false 1 cost 15.078021 refreshRate 8348418 bit true processName com.example.quiz_app_travel
W/DynamiteModule(13114): Local module descriptor class for com.google.android.gms.providerinstaller.dynamite not found.
I/DynamiteModule(13114): Considering local module com.google.android.gms.providerinstaller.dynamite:0 and remote module com.google.android.gms.providerinstaller.dynamite:0
W/ProviderInstaller(13114): Failed to load providerinstaller module: No acceptable module com.google.android.gms.providerinstaller.dynamite found. Local version is 0 and remote version is 0.
D/nativeloader(13114): Configuring clns-7 for other apk /system/framework/org.apache.http.legacy.jar. target_sdk_version=37, uses_libraries=ALL, library_path=/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/lib/arm64:/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/base.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand:/data/user/0/com.google.android.gms
D/nativeloader(13114): Extending system_exposed_libraries: libbinauralrenderer_wrapper.qti.so:libhoaeffects.qti.so:libSloganJni.oplus.so:libsuperNight.oplus.so:libupdateprof.qti.so:libQOC.qti.so:libthermalclient.qti.so:libdiag_system.qti.so:libqape.qti.so:liblistenjni.qti.so
W/quiz_app_travel(13114): Loading /data/misc/apexdata/com.android.art/dalvik-cache/arm64/system@framework@com.android.location.provider.jar@classes.odex non-executable as it requires an image which we failed to load
D/nativeloader(13114): Configuring clns-8 for other apk /system/framework/com.android.location.provider.jar. target_sdk_version=37, uses_libraries=ALL, library_path=/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/lib/arm64:/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/base.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand:/data/user/0/com.google.android.gms
D/nativeloader(13114): Extending system_exposed_libraries: libbinauralrenderer_wrapper.qti.so:libhoaeffects.qti.so:libSloganJni.oplus.so:libsuperNight.oplus.so:libupdateprof.qti.so:libQOC.qti.so:libthermalclient.qti.so:libdiag_system.qti.so:libqape.qti.so:liblistenjni.qti.so
D/nativeloader(13114): Configuring clns-9 for other apk /system/framework/com.android.media.remotedisplay.jar. target_sdk_version=37, uses_libraries=ALL, library_path=/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/lib/arm64:/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/base.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand:/data/user/0/com.google.android.gms
D/nativeloader(13114): Extending system_exposed_libraries: libbinauralrenderer_wrapper.qti.so:libhoaeffects.qti.so:libSloganJni.oplus.so:libsuperNight.oplus.so:libupdateprof.qti.so:libQOC.qti.so:libthermalclient.qti.so:libdiag_system.qti.so:libqape.qti.so:liblistenjni.qti.so
D/nativeloader(13114): Configuring clns-10 for other apk /data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/base.apk. target_sdk_version=37, uses_libraries=, library_path=/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/lib/arm64:/data/app/~~fQx3trgIyP4TEPieYZ9k2A==/com.google.android.gms-l9JnBMvJnf2BKtw8cmxfRA==/base.apk!/lib/arm64-v8a, permitted_path=/data:/mnt/expand:/data/user/0/com.google.android.gms
I/quiz_app_travel(13114): hiddenapi: Accessing hidden method Ldalvik/system/VMStack;->getStackClass2()Ljava/lang/Class; (runtime_flags=0, domain=core-platform, api=unsupported) from Lhjfh; (domain=app, TargetSdkVersion=36) using reflection: allowed
I/ProviderInstaller(13114): Installed default security provider AndroidOpenSSL (via CompatProvider)
E/GoogleApiManager(13114): Failed to get service from broker.
E/GoogleApiManager(13114): java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
E/GoogleApiManager(13114): 	at android.os.Parcel.createExceptionOrNull(Parcel.java:3040)
E/GoogleApiManager(13114): 	at android.os.Parcel.createException(Parcel.java:3024)
E/GoogleApiManager(13114): 	at android.os.Parcel.readException(Parcel.java:3007)
E/GoogleApiManager(13114): 	at android.os.Parcel.readException(Parcel.java:2949)
E/GoogleApiManager(13114): 	at bjvt.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):36)
E/GoogleApiManager(13114): 	at bjtp.y(:com.google.android.gms@262634029@26.26.34 (190400-945364269):144)
E/GoogleApiManager(13114): 	at bizr.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):42)
E/GoogleApiManager(13114): 	at android.os.Handler.handleCallback(Handler.java:942)
E/GoogleApiManager(13114): 	at android.os.Handler.dispatchMessage(Handler.java:99)
E/GoogleApiManager(13114): 	at dbjk.mX(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
E/GoogleApiManager(13114): 	at dbjk.dispatchMessage(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
E/GoogleApiManager(13114): 	at android.os.Looper.loopOnce(Looper.java:240)
E/GoogleApiManager(13114): 	at android.os.Looper.loop(Looper.java:351)
E/GoogleApiManager(13114): 	at android.os.HandlerThread.run(HandlerThread.java:67)
W/GoogleApiManager(13114): Not showing notification since connectionResult is not user-facing: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagRegistrar(13114): Failed to register com.google.android.gms.providerinstaller#com.example.quiz_app_travel
W/FlagRegistrar(13114): goep: 17: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagRegistrar(13114): 	at goer.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):13)
W/FlagRegistrar(13114): 	at hovj.d(:com.google.android.gms@262634029@26.26.34 (190400-945364269):3)
W/FlagRegistrar(13114): 	at hovl.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):139)
W/FlagRegistrar(13114): 	at hoxw.execute(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagRegistrar(13114): 	at hovt.f(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagRegistrar(13114): 	at hovt.m(:com.google.android.gms@262634029@26.26.34 (190400-945364269):101)
W/FlagRegistrar(13114): 	at hovt.q(:com.google.android.gms@262634029@26.26.34 (190400-945364269):16)
W/FlagRegistrar(13114): 	at ghlz.hM(:com.google.android.gms@262634029@26.26.34 (190400-945364269):35)
W/FlagRegistrar(13114): 	at ftma.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):12)
W/FlagRegistrar(13114): 	at hoxw.execute(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagRegistrar(13114): 	at ftmb.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):18)
W/FlagRegistrar(13114): 	at ftmq.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):34)
W/FlagRegistrar(13114): 	at ftms.c(:com.google.android.gms@262634029@26.26.34 (190400-945364269):23)
W/FlagRegistrar(13114): 	at biwy.e(:com.google.android.gms@262634029@26.26.34 (190400-945364269):9)
W/FlagRegistrar(13114): 	at bizp.q(:com.google.android.gms@262634029@26.26.34 (190400-945364269):48)
W/FlagRegistrar(13114): 	at bizp.d(:com.google.android.gms@262634029@26.26.34 (190400-945364269):10)
W/FlagRegistrar(13114): 	at bizp.g(:com.google.android.gms@262634029@26.26.34 (190400-945364269):191)
W/FlagRegistrar(13114): 	at bizp.onConnectionFailed(:com.google.android.gms@262634029@26.26.34 (190400-945364269):2)
W/FlagRegistrar(13114): 	at bizr.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):70)
W/FlagRegistrar(13114): 	at android.os.Handler.handleCallback(Handler.java:942)
W/FlagRegistrar(13114): 	at android.os.Handler.dispatchMessage(Handler.java:99)
W/FlagRegistrar(13114): 	at dbjk.mX(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagRegistrar(13114): 	at dbjk.dispatchMessage(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
W/FlagRegistrar(13114): 	at android.os.Looper.loopOnce(Looper.java:240)
W/FlagRegistrar(13114): 	at android.os.Looper.loop(Looper.java:351)
W/FlagRegistrar(13114): 	at android.os.HandlerThread.run(HandlerThread.java:67)
W/FlagRegistrar(13114): Caused by: bivd: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagRegistrar(13114): 	at bjtb.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):15)
W/FlagRegistrar(13114): 	at bixb.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagRegistrar(13114): 	at biwy.e(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
W/FlagRegistrar(13114): 	... 12 more
W/FlagStore(13114): Unable to update local snapshot for com.google.android.gms.providerinstaller#com.example.quiz_app_travel, may result in stale flags.
W/FlagStore(13114): java.util.concurrent.ExecutionException: goep: 17: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagStore(13114): 	at hovt.j(:com.google.android.gms@262634029@26.26.34 (190400-945364269):21)
W/FlagStore(13114): 	at howc.t(:com.google.android.gms@262634029@26.26.34 (190400-945364269):24)
W/FlagStore(13114): 	at hovt.get(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at hpal.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):2)
W/FlagStore(13114): 	at hozb.s(:com.google.android.gms@262634029@26.26.34 (190400-945364269):10)
W/FlagStore(13114): 	at gojz.d(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at gojd.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
W/FlagStore(13114): 	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:520)
W/FlagStore(13114): 	at java.util.concurrent.FutureTask.run(FutureTask.java:328)
W/FlagStore(13114): 	at java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask.run(ScheduledThreadPoolExecutor.java:323)
W/FlagStore(13114): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1100)
W/FlagStore(13114): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
W/FlagStore(13114): 	at java.lang.Thread.run(Thread.java:1572)
W/FlagStore(13114): Caused by: goep: 17: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagStore(13114): 	at goer.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):13)
W/FlagStore(13114): 	at hovj.d(:com.google.android.gms@262634029@26.26.34 (190400-945364269):3)
W/FlagStore(13114): 	at hovl.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):139)
W/FlagStore(13114): 	at hoxw.execute(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at hovt.f(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at hovt.m(:com.google.android.gms@262634029@26.26.34 (190400-945364269):101)
W/FlagStore(13114): 	at hovt.q(:com.google.android.gms@262634029@26.26.34 (190400-945364269):16)
W/FlagStore(13114): 	at ghlz.hM(:com.google.android.gms@262634029@26.26.34 (190400-945364269):35)
W/FlagStore(13114): 	at ftma.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):12)
W/FlagStore(13114): 	at hoxw.execute(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at ftmb.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):18)
W/FlagStore(13114): 	at ftmq.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):34)
W/FlagStore(13114): 	at ftmx.B(:com.google.android.gms@262634029@26.26.34 (190400-945364269):17)
W/FlagStore(13114): 	at ftls.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):60)
W/FlagStore(13114): 	at hoxw.execute(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at ftlt.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):8)
W/FlagStore(13114): 	at ftmq.b(:com.google.android.gms@262634029@26.26.34 (190400-945364269):34)
W/FlagStore(13114): 	at ftms.c(:com.google.android.gms@262634029@26.26.34 (190400-945364269):23)
W/FlagStore(13114): 	at biwy.e(:com.google.android.gms@262634029@26.26.34 (190400-945364269):9)
W/FlagStore(13114): 	at bizp.q(:com.google.android.gms@262634029@26.26.34 (190400-945364269):48)
W/FlagStore(13114): 	at bizp.d(:com.google.android.gms@262634029@26.26.34 (190400-945364269):10)
W/FlagStore(13114): 	at bizp.g(:com.google.android.gms@262634029@26.26.34 (190400-945364269):191)
W/FlagStore(13114): 	at bizp.onConnectionFailed(:com.google.android.gms@262634029@26.26.34 (190400-945364269):2)
W/FlagStore(13114): 	at bizr.run(:com.google.android.gms@262634029@26.26.34 (190400-945364269):70)
W/FlagStore(13114): 	at android.os.Handler.handleCallback(Handler.java:942)
W/FlagStore(13114): 	at android.os.Handler.dispatchMessage(Handler.java:99)
W/FlagStore(13114): 	at dbjk.mX(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at dbjk.dispatchMessage(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
W/FlagStore(13114): 	at android.os.Looper.loopOnce(Looper.java:240)
W/FlagStore(13114): 	at android.os.Looper.loop(Looper.java:351)
W/FlagStore(13114): 	at android.os.HandlerThread.run(HandlerThread.java:67)
W/FlagStore(13114): Caused by: bivd: 17: API: Phenotype.API is not available on this device. Connection failed with: ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null, clientMethodKey=null}
W/FlagStore(13114): 	at bjtb.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):15)
W/FlagStore(13114): 	at bixb.a(:com.google.android.gms@262634029@26.26.34 (190400-945364269):1)
W/FlagStore(13114): 	at biwy.e(:com.google.android.gms@262634029@26.26.34 (190400-945364269):5)
W/FlagStore(13114): 	... 12 more
W/FeatureFlagsImplExport(13114): java.lang.NoClassDefFoundError: Class not found using the boot class loader; no stack trace available
D/VRI[MainActivity](13114):  debugCancelDraw some OnPreDrawListener onPreDraw return false,cancelDraw=true,count=50,android.view.ViewRootImpl@54956bc
