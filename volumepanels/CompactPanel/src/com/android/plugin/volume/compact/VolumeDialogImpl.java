/*
 * Copyright (C) 2015 The Android Open Source Project
 * Copyright (C) 2020 The Potato Open Sauce Project
 * Copyright (C) 2021 crDroid Android Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.plugin.volume.compact;

import static android.app.ActivityManager.LOCK_TASK_MODE_NONE;
import static android.media.AudioManager.RINGER_MODE_NORMAL;
import static android.media.AudioManager.RINGER_MODE_SILENT;
import static android.media.AudioManager.RINGER_MODE_VIBRATE;
import static android.media.AudioManager.STREAM_ACCESSIBILITY;
import static android.media.AudioManager.STREAM_ALARM;
import static android.media.AudioManager.STREAM_MUSIC;
import static android.media.AudioManager.STREAM_NOTIFICATION;
import static android.media.AudioManager.STREAM_RING;
import static android.media.AudioManager.STREAM_VOICE_CALL;
import static android.view.View.ACCESSIBILITY_LIVE_REGION_POLITE;
import static android.view.View.GONE;
import static android.view.View.INVISIBLE;
import static android.view.View.VISIBLE;

import static com.android.plugin.volume.common.Events.DISMISS_REASON_SETTINGS_CLICKED;

import android.animation.ObjectAnimator;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.Dialog;
import android.app.KeyguardManager;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothProfile;
import android.content.ContentResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.Region;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.media.AudioManager;
import android.media.AudioSystem;
import android.os.Debug;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.os.VibrationEffect;
import android.provider.Settings;
import android.provider.Settings.Global;
import android.text.InputFilter;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.Slog;
import android.util.SparseBooleanArray;
import android.view.ContextThemeWrapper;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.AccessibilityDelegate;
import android.view.ViewGroup;
import android.view.ViewPropertyAnimator;
import android.view.ViewStub;
import android.view.ViewTreeObserver;
import android.view.ViewTreeObserver.InternalInsetsInfo;
import android.view.ViewTreeObserver.OnComputeInternalInsetsListener;
import android.view.Window;
import android.view.WindowManager;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityManager;
import android.view.accessibility.AccessibilityNodeInfo;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import android.widget.Toast;

import com.android.plugin.volume.common.*;

import com.android.plugin.volume.compact.R;

import com.android.systemui.plugins.ActivityStarter;
import com.android.systemui.plugins.PluginDependency;
import com.android.systemui.plugins.VolumeDialog;
import com.android.systemui.plugins.VolumeDialogController;
import com.android.systemui.plugins.VolumeDialogController.State;
import com.android.systemui.plugins.VolumeDialogController.StreamState;
import com.android.systemui.plugins.annotations.Requires;

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Visual presentation of the volume dialog.
 *
 * A client of VolumeDialogControllerImpl and its state model.
 *
 * Methods ending in "H" must be called on the (ui) handler.
 */
@Requires(target = VolumeDialog.class, version = VolumeDialog.VERSION)
@Requires(target = VolumeDialog.Callback.class, version = VolumeDialog.Callback.VERSION)
@Requires(target = VolumeDialogController.class, version = VolumeDialogController.VERSION)
@Requires(target = ActivityStarter.class, version = ActivityStarter.VERSION)
public class VolumeDialogImpl extends PanelSideAware implements VolumeDialog {
    private static final String TAG = Utils.logTag(VolumeDialogImpl.class);
    public static final String ACTION_MEDIA_OUTPUT =
            "com.android.settings.panel.action.MEDIA_OUTPUT";

    private static final long USER_ATTEMPT_GRACE_PERIOD = 1000;
    private static final int UPDATE_ANIMATION_DURATION = 80;

    static final int DIALOG_TIMEOUT_MILLIS = 3000;
    static final int DIALOG_SAFETYWARNING_TIMEOUT_MILLIS = 5000;
    static final int DIALOG_ODI_CAPTIONS_TOOLTIP_TIMEOUT_MILLIS = 5000;
    static final int DIALOG_HOVERING_TIMEOUT_MILLIS = 16000;
    static final int DIALOG_SHOW_ANIMATION_DURATION = 300;
    static final int DIALOG_HIDE_ANIMATION_DURATION = 250;

    private SysUIR mSysUIR;
    private Context mContext;
    private Context mSysUIContext;
    private WindowManager mWindowManager;
    private WindowManager.LayoutParams mWindowParams;
    private final H mHandler = new H();
    private VolumeDialogController mController;

    private View mDialog;
    private LinearLayout mDialogView;
    private ViewGroup mDialogRowsView;
    private ViewGroup mRinger;
    private ImageButton mRingerIcon;
    private ViewGroup mODICaptionsView;
    private CaptionsToggleImageButton mODICaptionsIcon;
    private View mMediaOutputContainer;
    private ImageButton mMediaOutputIcon;
    private FrameLayout mButtonsGroup;
    private View mExtraButtons;
    private View mExpandRowsView;
    private ExpandableIndicator mExpandRows;
    private FrameLayout mZenIcon;
    private final List<VolumeRow> mRows = new ArrayList<>();
    private ConfigurableTexts mConfigurableTexts;
    private final SparseBooleanArray mDynamic = new SparseBooleanArray();
    private KeyguardManager mKeyguard;
    private ActivityManager mActivityManager;
    private AccessibilityManager mAccessibilityMgr;
    private final Object mSafetyWarningLock = new Object();
    private final Accessibility mAccessibility = new Accessibility();

    private boolean mShowing;
    private boolean mShowA11yStream;

    private int mDisplayHeight;
    private int mActiveStream;
    private int mPrevActiveStream;
    private boolean mAutomute = VolumePrefs.DEFAULT_ENABLE_AUTOMUTE;
    private boolean mSilentMode = VolumePrefs.DEFAULT_ENABLE_SILENT_MODE;
    private State mState;
    private SafetyWarningDialog mSafetyWarning;
    private boolean mHovering = false;
    private boolean mShowActiveStreamOnly;
    private boolean mConfigChanged = false;
    private boolean mIsAnimatingDismiss = false;
    private boolean mHasSeenODICaptionsTooltip;
    private ViewStub mODICaptionsTooltipViewStub;
    private View mODICaptionsTooltipView = null;

    private PanelMode mPanelMode = PanelMode.MINI;

    public VolumeDialogImpl() {}

    @Override
    public void onCreate(Context sysuiContext, Context pluginContext) {
        mSysUIR = new SysUIR(pluginContext);
        mContext = pluginContext;
        mSysUIContext = 
                new ContextThemeWrapper(sysuiContext, mSysUIR.style("qs_theme", sysuiContext));
        mController = PluginDependency.get(this, VolumeDialogController.class);
        mAccessibilityMgr = mContext.getSystemService(AccessibilityManager.class);
        mKeyguard = (KeyguardManager) mContext.getSystemService(Context.KEYGUARD_SERVICE);
        mActivityManager = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
        mShowActiveStreamOnly = showActiveStreamOnly();
        mHasSeenODICaptionsTooltip =
                Prefs.getBoolean(sysuiContext, Prefs.Key.HAS_SEEN_ODI_CAPTIONS_TOOLTIP, false);
        initObserver(pluginContext, sysuiContext);
    }

    @Override
    public void init(int windowType, Callback callback) {
        initDialog();

        mAccessibility.init();

        mController.addCallback(mControllerCallbackH, mHandler);
        mController.getState();
    }


    @Override
    public void destroy() {
        mController.removeCallback(mControllerCallbackH);
        mHandler.removeCallbacksAndMessages(null);
    }

    @Override
    protected void onSideChange() {
        initDialog();
    }

    private void initDialog() {
        mWindowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);

        mSysUIContext.getTheme().applyStyle(mSysUIContext.getThemeResId(), true);
        mSysUIContext.getTheme().rebase();
        mContext.getTheme().setTo(mSysUIContext.getTheme());

        mConfigurableTexts = new ConfigurableTexts(mContext);
        mHovering = false;
        mShowing = false;
        mWindowParams = new WindowManager.LayoutParams();
        mWindowParams.flags &= ~WindowManager.LayoutParams.FLAG_DIM_BEHIND;
        mWindowParams.flags &= ~WindowManager.LayoutParams.FLAG_LAYOUT_INSET_DECOR;
        mWindowParams.flags |= WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE
                | WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL
                | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                | WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH
                | WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED;
        mWindowParams.type = WindowManager.LayoutParams.TYPE_VOLUME_OVERLAY;
        mWindowParams.format = PixelFormat.TRANSLUCENT;
        mWindowParams.windowAnimations = -1;
        mDialog = LayoutInflater.from(mContext).inflate(R.layout.volume_dialog_compact,
                        (ViewGroup) null, false);
        
        mDialog.setOnTouchListener((v, event) -> {
            if (mShowing) {
                switch (event.getAction()) {
                    case MotionEvent.ACTION_OUTSIDE:
                    case MotionEvent.ACTION_DOWN:
                        dismissH(Events.DISMISS_REASON_TOUCH_OUTSIDE);
                        return true;
                }
            }
            return false;
        });
        
        mDialogView = mDialog.findViewById(R.id.volume_dialog);
        mDialogView.setAlpha(0);

        mDialogView.setOnTouchListener((v, event) -> {
            int action = event.getActionMasked();
            mHovering = (action == MotionEvent.ACTION_HOVER_ENTER)
                    || (action == MotionEvent.ACTION_HOVER_MOVE);
            rescheduleTimeoutH();
            if(mPanelMode == PanelMode.MINI) {
                mPanelMode = PanelMode.COLLAPSED;
                updatePanelOnMode();
            }

            return true;
        });

        mDialogRowsView = mDialog.findViewById(R.id.volume_dialog_rows);
        mRinger = mDialog.findViewById(R.id.ringer);
        if (mRinger != null) {
            mRingerIcon = mRinger.findViewById(R.id.ringer_icon);
            mZenIcon = mRinger.findViewById(R.id.dnd_icon);
        }

        mButtonsGroup = mDialog.findViewById(R.id.buttons_group);
        mExtraButtons = mDialog.findViewById(R.id.extra_buttons);

        mODICaptionsView = mDialog.findViewById(R.id.odi_captions);
        if (mODICaptionsView != null) {
            mODICaptionsIcon = mODICaptionsView.findViewById(R.id.odi_captions_icon);
            mODICaptionsIcon.setImageDrawable(
                    mSysUIContext.getDrawable(mSysUIR.drawable("ic_volume_odi_captions_disabled")));
        }
        mODICaptionsTooltipViewStub = mDialog.findViewById(R.id.odi_captions_tooltip_stub);
        if (mHasSeenODICaptionsTooltip && mODICaptionsTooltipViewStub != null) {
            mDialogView.removeView(mODICaptionsTooltipViewStub);
            mODICaptionsTooltipViewStub = null;
        }

        mMediaOutputContainer = mDialog.findViewById(R.id.media_output_container);
        mMediaOutputIcon = mDialog.findViewById(R.id.media_output);

        mExpandRowsView = mDialog.findViewById(R.id.expandable_indicator_container);
        mExpandRows = mDialog.findViewById(R.id.expandable_indicator);

        if (mRows.isEmpty()) {
            if (!AudioSystem.isSingleVolume(mContext)) {
                addRow(STREAM_ACCESSIBILITY, mSysUIR.drawable("ic_volume_accessibility"),
                        mSysUIR.drawable("ic_volume_accessibility"), true, false);
            }
            addRow(AudioManager.STREAM_MUSIC,
                    mSysUIR.drawable("ic_volume_media"), mSysUIR.drawable("ic_volume_media_mute"), true, true);
            if (!AudioSystem.isSingleVolume(mContext)) {
                addRow(AudioManager.STREAM_RING,
                        mSysUIR.drawable("ic_volume_ringer"), mSysUIR.drawable("ic_volume_ringer_mute"), true, false);
                addRow(STREAM_ALARM,
                        mSysUIR.drawable("ic_volume_alarm"), mSysUIR.drawable("ic_volume_alarm_mute"), true, false);
                addRow(AudioManager.STREAM_VOICE_CALL,
                        com.android.internal.R.drawable.ic_phone,
                        com.android.internal.R.drawable.ic_phone, false, false);
                addRow(AudioManager.STREAM_BLUETOOTH_SCO,
                        mSysUIR.drawable("ic_volume_bt_sco"), mSysUIR.drawable("ic_volume_bt_sco"), false, false);
                addRow(AudioManager.STREAM_SYSTEM, mSysUIR.drawable("ic_volume_system"),
                        mSysUIR.drawable("ic_volume_system_mute"), false, false);
            }
        } else {
            addExistingRows();
        }

        FrameLayout.LayoutParams dialogViewLP =
                (FrameLayout.LayoutParams) mDialogView.getLayoutParams();
        LinearLayout.LayoutParams mainFrameLP =
                (LinearLayout.LayoutParams) mDialog.findViewById(R.id.main_frame).getLayoutParams();
        LinearLayout.LayoutParams buttonsGroupLP =
                (LinearLayout.LayoutParams) mButtonsGroup.getLayoutParams();
        FrameLayout.LayoutParams baseButtonsLP =
                (FrameLayout.LayoutParams) mDialog.findViewById(R.id.base_buttons).getLayoutParams();
        FrameLayout.LayoutParams extraButtonsLP =
                (FrameLayout.LayoutParams) mExtraButtons.getLayoutParams();

        dialogViewLP.gravity = Gravity.CENTER_VERTICAL;
        if (!isAudioPanelOnLeftSide()) {
            mainFrameLP.gravity = Gravity.RIGHT | Gravity.CENTER_VERTICAL;
            buttonsGroupLP.gravity = Gravity.RIGHT | Gravity.CENTER_VERTICAL;
            mExpandRows.setRotation(90);
            baseButtonsLP.gravity = Gravity.RIGHT;
            extraButtonsLP.gravity = Gravity.LEFT;
        } else {
            mainFrameLP.gravity = Gravity.LEFT | Gravity.CENTER_VERTICAL;
            buttonsGroupLP.gravity = Gravity.LEFT | Gravity.CENTER_VERTICAL;
            mExpandRows.setRotation(-90);
            baseButtonsLP.gravity = Gravity.LEFT;
            extraButtonsLP.gravity = Gravity.RIGHT;
        }
        mDialogView.setLayoutParams(dialogViewLP);
        mDialog.findViewById(R.id.main_frame).setLayoutParams(mainFrameLP);
        mButtonsGroup.setLayoutParams(buttonsGroupLP);
        mDialog.findViewById(R.id.base_buttons).setLayoutParams(baseButtonsLP);
        mExtraButtons.setLayoutParams(extraButtonsLP);

        updateRowsH(getActiveRow());
        updatePanelOnMode();
        initRingerH();
        initSettingsH();
        initODICaptionsH();
    }

    private final OnComputeInternalInsetsListener mInsetsListener = internalInsetsInfo -> {
        internalInsetsInfo.touchableRegion.setEmpty();
        internalInsetsInfo.setTouchableInsets(InternalInsetsInfo.TOUCHABLE_INSETS_REGION);
        View main = mDialog.findViewById(R.id.main);
        int[] mainLocation = new int[2];
        main.getLocationInWindow(mainLocation);
        internalInsetsInfo.touchableRegion.set(
            mainLocation[0],
            mainLocation[1],
            mainLocation[0] + main.getWidth(),
            mPanelMode == PanelMode.MINI
                ? mainLocation[1] + main.getHeight()
                : mainLocation[1] + mDialogView.getHeight()
        );
    };

    protected ViewGroup getDialogView() {
        return mDialogView;
    }

    private int getAlphaAttr(int attr) {
        TypedArray ta = mContext.obtainStyledAttributes(new int[]{attr});
        float alpha = ta.getFloat(0, 0);
        ta.recycle();
        return (int) (alpha * 255);
    }

    private boolean isLandscape() {
        return mContext.getResources().getConfiguration().orientation ==
                Configuration.ORIENTATION_LANDSCAPE;
    }

    public void setStreamImportant(int stream, boolean important) {
        mHandler.obtainMessage(H.SET_STREAM_IMPORTANT, stream, important ? 1 : 0).sendToTarget();
    }

    public void setAutomute(boolean automute) {
        if (mAutomute == automute) return;
        mAutomute = automute;
        mHandler.sendEmptyMessage(H.RECHECK_ALL);
    }

    public void setSilentMode(boolean silentMode) {
        if (mSilentMode == silentMode) return;
        mSilentMode = silentMode;
        mHandler.sendEmptyMessage(H.RECHECK_ALL);
    }

    private void addRow(int stream, int iconRes, int iconMuteRes, boolean important,
            boolean defaultStream) {
        addRow(stream, iconRes, iconMuteRes, important, defaultStream, false);
    }

    private void addRow(int stream, int iconRes, int iconMuteRes, boolean important,
            boolean defaultStream, boolean dynamic) {
        if (D.BUG) Slog.d(TAG, "Adding row for stream " + stream);
        VolumeRow row = new VolumeRow();
        initRow(row, stream, iconRes, iconMuteRes, important, defaultStream);
        if (!isAudioPanelOnLeftSide()) {
            mDialogRowsView.addView(row.view, 0);
        } else {
            mDialogRowsView.addView(row.view);
        }
        mRows.add(0, row);
    }

    private void addExistingRows() {
        int N = mRows.size();
        for (int i = 0; i < N; i++) {
            final VolumeRow row = mRows.get(i);
            initRow(row, row.stream, row.iconRes, row.iconMuteRes, row.important,
                    row.defaultStream);
            if(!isAudioPanelOnLeftSide()){
                mDialogRowsView.addView(row.view, 0);
            } else {
                mDialogRowsView.addView(row.view);
            }
            updateVolumeRowH(row);
        }
    }

    private void cleanExpandedRows() {
        for (int i = mRows.size() - 1; i >= 0; i--) {
            final VolumeRow row = mRows.get(i);
            if (row.stream == AudioManager.STREAM_RING || row.stream == AudioManager.STREAM_ALARM) {
                removeRow(row);
            }
        }
    }

    private void updateAllActiveRows() {
        int N = mRows.size();
        for (int i = 0; i < N; i++) {
            updateVolumeRowH(mRows.get(i));
        }
    }

    private VolumeRow getActiveRow() {
        for (VolumeRow row : mRows) {
            if (row.stream == mActiveStream) {
                return row;
            }
        }
        for (VolumeRow row : mRows) {
            if (row.stream == STREAM_MUSIC) {
                return row;
            }
        }
        return mRows.get(0);
    }

    private VolumeRow findRow(int stream) {
        for (VolumeRow row : mRows) {
            if (row.stream == stream) return row;
        }
        return null;
    }

    public void dump(PrintWriter writer) {
        writer.println(VolumeDialogImpl.class.getSimpleName() + " state:");
        writer.print("  mShowing: "); writer.println(mShowing);
        writer.print("  mActiveStream: "); writer.println(mActiveStream);
        writer.print("  mDynamic: "); writer.println(mDynamic);
        writer.print("  mAutomute: "); writer.println(mAutomute);
        writer.print("  mSilentMode: "); writer.println(mSilentMode);
    }

    private static int getImpliedLevel(SeekBar seekBar, int progress) {
        final int m = seekBar.getMax();
        final int n = m / 100 - 1;
        final int level = progress == 0 ? 0
                : progress == m ? (m / 100) : (1 + (int)((progress / (float) m) * n));
        return level;
    }

    @SuppressLint("InflateParams")
    private void initRow(final VolumeRow row, final int stream, int iconRes, int iconMuteRes,
            boolean important, boolean defaultStream) {
        row.stream = stream;
        row.iconRes = iconRes;
        row.iconMuteRes = iconMuteRes;
        row.important = important;
        row.defaultStream = defaultStream;
        row.view = LayoutInflater.from(mContext).inflate(R.layout.volume_dialog_compact_row, null);
        row.view.setId(row.stream);
        row.view.setTag(row);
        row.header = row.view.findViewById(R.id.volume_row_header);
        row.header.setId(20 * row.stream);
        if (stream == STREAM_ACCESSIBILITY) {
            row.header.setFilters(new InputFilter[] {new InputFilter.LengthFilter(13)});
        }
        row.dndIcon = row.view.findViewById(R.id.dnd_icon);
        row.slider = row.view.findViewById(R.id.volume_row_slider);
        row.slider.setOnSeekBarChangeListener(new VolumeSeekBarChangeListener(row));

        row.anim = null;

        row.icon = row.view.findViewById(R.id.volume_row_icon);
        Drawable iconResDrawable = mSysUIContext.getDrawable(iconRes);
        row.icon.setImageDrawable(iconResDrawable);
        if (row.stream != AudioSystem.STREAM_ACCESSIBILITY) {
            row.icon.setOnClickListener(v -> {
                Events.writeEvent(Events.EVENT_ICON_CLICK, row.stream, row.iconState);
                rescheduleTimeoutH();
                mController.setActiveStream(row.stream);
                if (row.stream == AudioManager.STREAM_RING) {
                    final boolean hasVibrator = mController.hasVibrator();
                    if (mState.ringerModeInternal == AudioManager.RINGER_MODE_NORMAL) {
                        if (hasVibrator) {
                            mController.setRingerMode(AudioManager.RINGER_MODE_VIBRATE, false);
                        } else {
                            final boolean wasZero = row.ss.level == 0;
                            mController.setStreamVolume(stream,
                                    wasZero ? row.lastAudibleLevel : 0);
                        }
                    } else {
                        mController.setRingerMode(AudioManager.RINGER_MODE_NORMAL, false);
                        if (row.ss.level == 0) {
                            mController.setStreamVolume(stream, 1);
                        }
                    }
                } else {
                    final boolean vmute = row.ss.level == row.ss.levelMin;
                    mController.setStreamVolume(stream,
                            vmute ? row.lastAudibleLevel : row.ss.levelMin);
                }
                row.userAttempt = 0;  // reset the grace period, slider updates immediately
            });
        } else {
            row.icon.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_NO);
        }
    }

    private static boolean isBluetoothA2dpConnected() {
        BluetoothAdapter mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        return mBluetoothAdapter != null && mBluetoothAdapter.isEnabled()
                && mBluetoothAdapter.getProfileConnectionState(BluetoothProfile.A2DP)
                == BluetoothProfile.STATE_CONNECTED;
    }

    public void initSettingsH() {
        if (mExpandRowsView != null) {
            mExpandRowsView.setVisibility(
                    mActivityManager.getLockTaskModeState() == LOCK_TASK_MODE_NONE ?
                            VISIBLE : GONE);
        }

        if (mExpandRows != null) {
            mExpandRows.setOnLongClickListener(v -> {
                rescheduleTimeoutH();
                Events.writeEvent(Events.EVENT_SETTINGS_CLICK);
                Intent intent = new Intent(Settings.ACTION_SOUND_SETTINGS);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                dismissH(DISMISS_REASON_SETTINGS_CLICKED);
                PluginDependency.get(this, ActivityStarter.class).startActivity(intent,
                        true /* dismissShade */);
                return true;
            });
            mExpandRows.setOnClickListener(v -> {
                rescheduleTimeoutH();
                if (mPanelMode != PanelMode.EXPANDED) {
                    addRow(AudioManager.STREAM_RING, mSysUIR.drawable("ic_volume_ringer"),
                            mSysUIR.drawable("ic_volume_ringer_mute"), true, false);
                    addRow(AudioManager.STREAM_ALARM, mSysUIR.drawable("ic_volume_alarm"),
                            mSysUIR.drawable("ic_volume_alarm_mute"), true, false);
                    updateAllActiveRows();
                    mPanelMode = PanelMode.EXPANDED;
                    updatePanelOnMode();
                } else {
                    cleanExpandedRows();
                    mPanelMode = PanelMode.COLLAPSED;
                    updatePanelOnMode();
                }
                mExpandRows.setExpanded(mPanelMode == PanelMode.EXPANDED);
            });
        }

        if (mMediaOutputContainer != null) {
            mMediaOutputContainer.setVisibility(
                    mActivityManager.getLockTaskModeState() == LOCK_TASK_MODE_NONE &&
                            isBluetoothA2dpConnected() ? VISIBLE : GONE);
        }
        
        if (mMediaOutputIcon != null) {
            mMediaOutputIcon.setOnClickListener(v -> {
                Events.writeEvent(Events.EVENT_SETTINGS_CLICK);
                Intent intent = new Intent(ACTION_MEDIA_OUTPUT);
                dismissH(DISMISS_REASON_SETTINGS_CLICKED);
                PluginDependency.get(this, ActivityStarter.class).startActivity(intent,
                        true /* dismissShade */);
            });
        }
    }

    public void initRingerH() {
        if (mRingerIcon != null) {
            mRingerIcon.setAccessibilityLiveRegion(ACCESSIBILITY_LIVE_REGION_POLITE);
            mRingerIcon.setOnClickListener(v -> {
                rescheduleTimeoutH();
                Prefs.putBoolean(mSysUIContext, Prefs.Key.TOUCHED_RINGER_TOGGLE, true);
                final StreamState ss = mState.states.get(AudioManager.STREAM_RING);
                if (ss == null) {
                    return;
                }
                // normal -> vibrate -> silent -> normal (skip vibrate if device doesn't have
                // a vibrator.
                int newRingerMode;
                final boolean hasVibrator = mController.hasVibrator();
                if (mState.ringerModeInternal == AudioManager.RINGER_MODE_NORMAL) {
                    if (hasVibrator) {
                        newRingerMode = AudioManager.RINGER_MODE_VIBRATE;
                    } else {
                        newRingerMode = AudioManager.RINGER_MODE_SILENT;
                    }
                } else if (mState.ringerModeInternal == AudioManager.RINGER_MODE_VIBRATE) {
                    newRingerMode = AudioManager.RINGER_MODE_SILENT;
                } else {
                    newRingerMode = AudioManager.RINGER_MODE_NORMAL;
                    if (ss.level == 0) {
                        mController.setStreamVolume(AudioManager.STREAM_RING, 1);
                    }
                }
                Events.writeEvent(Events.EVENT_RINGER_TOGGLE, newRingerMode);
                incrementManualToggleCount();
                updateRingerH();
                provideTouchFeedbackH(newRingerMode);
                mController.setRingerMode(newRingerMode, false);
                maybeShowToastH(newRingerMode);
            });
        }
        updateRingerH();
    }

    private void initODICaptionsH() {
        if (mODICaptionsIcon != null) {
            mODICaptionsIcon.setOnConfirmedTapListener(() -> {
                rescheduleTimeoutH();
                onCaptionIconClicked();
                Events.writeEvent(Events.EVENT_ODI_CAPTIONS_CLICK);
            }, mHandler);
        }

        mController.getCaptionsComponentState(false);
    }

    private void checkODICaptionsTooltip(boolean fromDismiss) {
        if (!mHasSeenODICaptionsTooltip && !fromDismiss && mODICaptionsTooltipViewStub != null) {
            mController.getCaptionsComponentState(true);
        } else {
            if (mHasSeenODICaptionsTooltip && fromDismiss && mODICaptionsTooltipView != null) {
                hideCaptionsTooltip();
            }
        }
    }

    protected void showCaptionsTooltip() {
        if (!mHasSeenODICaptionsTooltip && mODICaptionsTooltipViewStub != null) {
            mODICaptionsTooltipView = mODICaptionsTooltipViewStub.inflate();
            mODICaptionsTooltipView.findViewById(R.id.dismiss).setOnClickListener(v -> {
                rescheduleTimeoutH();
                hideCaptionsTooltip();
                Events.writeEvent(Events.EVENT_ODI_CAPTIONS_TOOLTIP_CLICK);
            });
            mODICaptionsTooltipViewStub = null;
        }

        if (mODICaptionsTooltipView != null) {
            mODICaptionsTooltipView.setAlpha(0.f);
            mODICaptionsTooltipView.animate()
                .alpha(1.f)
                .setStartDelay(DIALOG_SHOW_ANIMATION_DURATION)
                .withEndAction(() -> {
                    if (D.BUG) Log.d(TAG, "tool:checkODICaptionsTooltip() putBoolean true");
                    Prefs.putBoolean(mSysUIContext,
                            Prefs.Key.HAS_SEEN_ODI_CAPTIONS_TOOLTIP, true);
                    mHasSeenODICaptionsTooltip = true;
                    if (mODICaptionsIcon != null) {
                        mODICaptionsIcon
                                .postOnAnimation(getSinglePressFor(mODICaptionsIcon));
                    }
                })
                .start();
        }
    }

    private void hideCaptionsTooltip() {
        if (mODICaptionsTooltipView != null && mODICaptionsTooltipView.getVisibility() == VISIBLE) {
            mODICaptionsTooltipView.animate().cancel();
            mODICaptionsTooltipView.setAlpha(1.f);
            mODICaptionsTooltipView.animate()
                    .alpha(0.f)
                    .setStartDelay(0)
                    .setDuration(DIALOG_HIDE_ANIMATION_DURATION)
                    .withEndAction(() -> mODICaptionsTooltipView.setVisibility(INVISIBLE))
                    .start();
        }
    }

    protected void tryToRemoveCaptionsTooltip() {
        if (mHasSeenODICaptionsTooltip && mODICaptionsTooltipView != null) {
            ViewGroup container = mDialog.findViewById(R.id.volume_dialog_container);
            container.removeView(mODICaptionsTooltipView);
            mODICaptionsTooltipView = null;
        }
    }

    private void updatePanelOnMode() {
        Log.d(TAG, "updatePanelOnMode called");
        PanelMode mode = mPanelMode;

        for(final VolumeRow row : mRows) {
            ViewGroup.LayoutParams rowLP = row.view.getLayoutParams();

            if (mode != PanelMode.MINI) {
                row.slider.setThumb(mContext.getDrawable(R.drawable.seekbar_thumb_material_anim));
                row.icon.setVisibility(VISIBLE);
                rowLP.width = mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_row_width);
            } else {
                row.slider.setThumb(new ColorDrawable(Color.TRANSPARENT));
                row.icon.setVisibility(GONE);
                rowLP.width = mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_panel_mini_width);
            }
            row.view.setLayoutParams(rowLP);

            updateVolumeRowTintH(row, getActiveRow().equals(row));
        }

        LinearLayout main = (LinearLayout) mDialog.findViewById(R.id.main);
        View fakePadding = mDialog.findViewById(R.id.fake_padding);

        ViewPropertyAnimator buttonsAnimator = mButtonsGroup.animate()
                .alpha(1)
                .setDuration(350)
                .setInterpolator(new SystemUIInterpolators.LogAccelerateInterpolator());

        int rowSidePadding = mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_row_side_padding);

        if(mode != PanelMode.MINI) {
            if(mode == PanelMode.EXPANDED) {
                mExtraButtons.setVisibility(VISIBLE);
            } else if(mode == PanelMode.COLLAPSED) {
                mExtraButtons.setVisibility(GONE);
            }
            main.setMinimumWidth(mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_panel_width));
            mButtonsGroup.setVisibility(VISIBLE);
            mDialogRowsView.setPadding(rowSidePadding, 0, rowSidePadding, 0);
            fakePadding.setVisibility(GONE);
            buttonsAnimator.start();
        } else {
            main.setMinimumWidth(mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_panel_mini_width));
            mButtonsGroup.setVisibility(INVISIBLE);
            mExtraButtons.setVisibility(GONE);
            mDialogRowsView.setPadding(0, 0, 0, 0);
            fakePadding.setVisibility(VISIBLE);
            mButtonsGroup.setAlpha(0);
            mExtraButtons.setAlpha(0);
            buttonsAnimator.alpha(0);
        }
    }

    private void updateODICaptionsH(boolean isServiceComponentEnabled, boolean fromTooltip) {
        if (mODICaptionsView != null) {
            mODICaptionsView.setVisibility(isServiceComponentEnabled ? VISIBLE : GONE);
        }

        /*if(isServiceComponentEnabled) {
            WindowManager.LayoutParams lp = mWindow.getAttributes();
            lp.y = mDisplayHeight / 2 -
                    ((mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_caption_size) +
                            mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_total_height)) / 2);
            mWindow.setAttributes(lp);
        } else {
            WindowManager.LayoutParams lp = mWindow.getAttributes();
            lp.y = mDisplayHeight / 2 -
                    mContext.getResources().getDimensionPixelSize(R.dimen.volume_dialog_total_height) / 2;
            mWindow.setAttributes(lp);
        }*/

        if (!isServiceComponentEnabled) return;

        updateCaptionsIcon();
        if (fromTooltip) showCaptionsTooltip();
    }

    private void updateCaptionsIcon() {
        boolean captionsEnabled = mController.areCaptionsEnabled();
        if (mODICaptionsIcon.getCaptionsEnabled() != captionsEnabled) {
            mHandler.post(mODICaptionsIcon.setCaptionsEnabled(captionsEnabled));
        }

        boolean isOptedOut = mController.isCaptionStreamOptedOut();
        if (mODICaptionsIcon.getOptedOut() != isOptedOut) {
            mHandler.post(() -> mODICaptionsIcon.setOptedOut(isOptedOut));
        }
    }

    private void onCaptionIconClicked() {
        boolean isEnabled = mController.areCaptionsEnabled();
        mController.setCaptionsEnabled(!isEnabled);
        updateCaptionsIcon();
    }

    private void incrementManualToggleCount() {
        ContentResolver cr = mContext.getContentResolver();
        int ringerCount = Settings.Secure.getInt(cr, Settings.Secure.MANUAL_RINGER_TOGGLE_COUNT, 0);
        Settings.Secure.putInt(cr, Settings.Secure.MANUAL_RINGER_TOGGLE_COUNT, ringerCount + 1);
    }

    private void provideTouchFeedbackH(int newRingerMode) {
        VibrationEffect effect = null;
        switch (newRingerMode) {
            case RINGER_MODE_NORMAL:
                mController.scheduleTouchFeedback();
                break;
            case RINGER_MODE_SILENT:
                effect = VibrationEffect.get(VibrationEffect.EFFECT_CLICK);
                break;
            case RINGER_MODE_VIBRATE:
            default:
                effect = VibrationEffect.get(VibrationEffect.EFFECT_DOUBLE_CLICK);
        }
        if (effect != null) {
            mController.vibrate(effect);
        }
    }

    private void maybeShowToastH(int newRingerMode) {
        int seenToastCount = Prefs.getInt(mSysUIContext, Prefs.Key.SEEN_RINGER_GUIDANCE_COUNT, 0);

        if (seenToastCount > VolumePrefs.SHOW_RINGER_TOAST_COUNT) {
            return;
        }
        CharSequence toastText = null;
        switch (newRingerMode) {
            case RINGER_MODE_NORMAL:
                final StreamState ss = mState.states.get(AudioManager.STREAM_RING);
                if (ss != null) {
                    toastText = mSysUIContext.getString(
                            mSysUIR.string("volume_dialog_ringer_guidance_ring"),
                            Utils.formatPercentage(ss.level, ss.levelMax));
                }
                break;
            case RINGER_MODE_SILENT:
                toastText = mContext.getString(
                        com.android.internal.R.string.volume_dialog_ringer_guidance_silent);
                break;
            case RINGER_MODE_VIBRATE:
            default:
                toastText = mContext.getString(
                        com.android.internal.R.string.volume_dialog_ringer_guidance_vibrate);
        }

        Toast.makeText(mContext, toastText, Toast.LENGTH_SHORT).show();
        seenToastCount++;
        Prefs.putInt(mSysUIContext, Prefs.Key.SEEN_RINGER_GUIDANCE_COUNT, seenToastCount);
    }

    public void show(int reason) {
        mHandler.obtainMessage(H.SHOW, reason, 0).sendToTarget();
    }

    public void dismiss(int reason) {
        mHandler.obtainMessage(H.DISMISS, reason, 0).sendToTarget();
    }

    private void showH(int reason) {
        if (D.BUG) Log.d(TAG, "showH r=" + Events.SHOW_REASONS[reason]);
        mHandler.removeMessages(H.SHOW);
        mHandler.removeMessages(H.DISMISS);
        rescheduleTimeoutH();

        if (mConfigChanged) {
            initDialog(); // resets mShowing to false
            mConfigurableTexts.update();
            mConfigChanged = false;
        }

        initSettingsH();
        mIsAnimatingDismiss = false;
        mDialog.getViewTreeObserver().addOnComputeInternalInsetsListener(mInsetsListener);

        if(!mShowing && !mDialog.isShown()) {
            mDialogView.setTranslationX(0);
            mDialogView.setAlpha(0);
            mDialogView.animate()
                    .alpha(1)
                    .setDuration(DIALOG_SHOW_ANIMATION_DURATION)
                    .setInterpolator(new SystemUIInterpolators.LogDecelerateInterpolator())
                    .withStartAction(() -> {
                        if(!mDialog.isShown()) {
                            mWindowManager.addView(mDialog, mWindowParams);
                        }
                    })
                    .withEndAction(() -> {
                        if (!Prefs.getBoolean(mSysUIContext, Prefs.Key.TOUCHED_RINGER_TOGGLE, false)) {
                            if (mRingerIcon != null) {
                                mRingerIcon.postOnAnimationDelayed(
                                        getSinglePressFor(mRingerIcon), 1500);
                            }
                        }
                        mShowing = true;
                    })
                    .start();
        }
        Events.writeEvent(Events.EVENT_SHOW_DIALOG, reason, mKeyguard.isKeyguardLocked());
        mController.notifyVisible(true);
        mController.getCaptionsComponentState(false);
        checkODICaptionsTooltip(false);
    }

    protected void rescheduleTimeoutH() {
        mHandler.removeMessages(H.DISMISS);
        final int timeout = computeTimeoutH();
        mHandler.sendMessageDelayed(mHandler
                .obtainMessage(H.DISMISS, Events.DISMISS_REASON_TIMEOUT, 0), timeout);
        if (D.BUG) Log.d(TAG, "rescheduleTimeout " + timeout + " " + Debug.getCaller());
        mController.userActivity();
    }

    private int computeTimeoutH() {
        if (mHovering) {
            return mAccessibilityMgr.getRecommendedTimeoutMillis(DIALOG_HOVERING_TIMEOUT_MILLIS,
                    AccessibilityManager.FLAG_CONTENT_CONTROLS);
        }
        if (mSafetyWarning != null) {
            return mAccessibilityMgr.getRecommendedTimeoutMillis(
                    DIALOG_SAFETYWARNING_TIMEOUT_MILLIS,
                    AccessibilityManager.FLAG_CONTENT_TEXT
                            | AccessibilityManager.FLAG_CONTENT_CONTROLS);
        }
        if (!mHasSeenODICaptionsTooltip && mODICaptionsTooltipView != null) {
            return mAccessibilityMgr.getRecommendedTimeoutMillis(
                    DIALOG_ODI_CAPTIONS_TOOLTIP_TIMEOUT_MILLIS,
                    AccessibilityManager.FLAG_CONTENT_TEXT
                            | AccessibilityManager.FLAG_CONTENT_CONTROLS);
        }
        return mAccessibilityMgr.getRecommendedTimeoutMillis(DIALOG_TIMEOUT_MILLIS,
                AccessibilityManager.FLAG_CONTENT_CONTROLS);
    }

    protected void dismissH(int reason) {
        if (D.BUG) {
            Log.d(TAG, "mDialog.dismiss() reason: " + Events.DISMISS_REASONS[reason]
                    + " from: " + Debug.getCaller());
        }
        if (!mShowing) {
            // This may happen when dismissing an expanded panel, don't animate again
            return;
        }
        mHandler.removeMessages(H.DISMISS);
        mHandler.removeMessages(H.SHOW);
        if (mIsAnimatingDismiss) {
            return;
        }
        mIsAnimatingDismiss = true;
        mDialogView.animate().cancel();
        if (mShowing) {
            mShowing = false;
            // Only logs when the volume dialog visibility is changed.
            Events.writeEvent(Events.EVENT_DISMISS_DIALOG, reason);
        }
        
        if (mPanelMode != PanelMode.MINI)
            mDialogView.setTranslationX(0);

        mDialogView.setAlpha(1);
        ViewPropertyAnimator animator = mDialogView.animate()
                .alpha(0)
                .setDuration(DIALOG_HIDE_ANIMATION_DURATION)
                .setInterpolator(new SystemUIInterpolators.LogAccelerateInterpolator())
                .withEndAction(() -> mHandler.postDelayed(() -> {
                    mIsAnimatingDismiss = false;
                    if (mDialog.isShown()){
                        mWindowManager.removeViewImmediate(mDialog);
                    }
                    cleanExpandedRows();
                    mPanelMode = PanelMode.MINI;
                    mExpandRows.setExpanded(false);
                    updatePanelOnMode();
                    tryToRemoveCaptionsTooltip();
                }, 50));
        if (!isLandscape() && mPanelMode != PanelMode.MINI)
            animator.translationX((mDialogView.getWidth() / 2.0f)*(isAudioPanelOnLeftSide() ? -1 : 1));
        animator.start();
        mDialog.getViewTreeObserver().removeOnComputeInternalInsetsListener(mInsetsListener);
        checkODICaptionsTooltip(true);
        mController.notifyVisible(false);
        synchronized (mSafetyWarningLock) {
            if (mSafetyWarning != null) {
                if (D.BUG) Log.d(TAG, "SafetyWarning dismissed");
                mSafetyWarning.dismiss();
            }
        }
    }

    private boolean showActiveStreamOnly() {
        return mContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_LEANBACK)
                || mContext.getPackageManager().hasSystemFeature(PackageManager.FEATURE_TELEVISION);
    }

    private boolean shouldBeVisibleH(VolumeRow row, VolumeRow activeRow) {
        boolean isActive = row.stream == activeRow.stream;

        if (isActive) {
            return true;
        }

        if (!mShowActiveStreamOnly) {
            if (row.stream == AudioSystem.STREAM_ACCESSIBILITY) {
                return mShowA11yStream;
            }

            // if the active row is accessibility, then continue to display previous
            // active row since accessibility is displayed under it
            if (activeRow.stream == AudioSystem.STREAM_ACCESSIBILITY &&
                    row.stream == mPrevActiveStream) {
                return true;
            }

            if (row.defaultStream) {
                return activeRow.stream == STREAM_RING
                        || activeRow.stream == STREAM_NOTIFICATION
                        || activeRow.stream == STREAM_ALARM
                        || activeRow.stream == STREAM_VOICE_CALL
                        || activeRow.stream == STREAM_ACCESSIBILITY
                        || mDynamic.get(activeRow.stream);
            }
        }

        return false;
    }

    private void updateRowsH(final VolumeRow activeRow) {
        if (D.BUG) Log.d(TAG, "updateRowsH");
        if (!mShowing) {
            trimObsoleteH();
        }
        // apply changes to all rows
        for (final VolumeRow row : mRows) {
            final boolean isActive = row == activeRow;
            final boolean shouldBeVisible = shouldBeVisibleH(row, activeRow);
            if (mPanelMode != PanelMode.EXPANDED) {
                Utils.setVisOrGone(row.view, shouldBeVisible);
            }
            if (row.view.isShown()) {
                updateVolumeRowTintH(row, isActive);
            }
        }
    }

    private void updateRingerH() {
        if (mRinger != null && mState != null) {
            final StreamState ss = mState.states.get(AudioManager.STREAM_RING);
            if (ss == null) {
                return;
            }

            boolean isZenMuted = mState.zenMode == Global.ZEN_MODE_ALARMS
                    || mState.zenMode == Global.ZEN_MODE_NO_INTERRUPTIONS
                    || (mState.zenMode == Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS
                        && mState.disallowRinger);
            enableRingerViewsH(!isZenMuted);
            Drawable ringerDrawable;
            switch (mState.ringerModeInternal) {
                case AudioManager.RINGER_MODE_VIBRATE:
                    ringerDrawable = mSysUIContext.getDrawable(
                        mSysUIR.drawable("ic_volume_ringer_vibrate"));
                    addAccessibilityDescription(mRingerIcon, RINGER_MODE_VIBRATE,
                            mSysUIContext.getString(mSysUIR.string("volume_ringer_hint_mute")));
                    mRingerIcon.setTag(Events.ICON_STATE_VIBRATE);
                    break;
                case AudioManager.RINGER_MODE_SILENT:
                    ringerDrawable = mSysUIContext.getDrawable(
                        mSysUIR.drawable("ic_volume_ringer_mute"));
                    mRingerIcon.setTag(Events.ICON_STATE_MUTE);
                    addAccessibilityDescription(mRingerIcon, RINGER_MODE_SILENT,
                            mSysUIContext.getString(mSysUIR.string("volume_ringer_hint_unmute")));
                    break;
                case AudioManager.RINGER_MODE_NORMAL:
                default:
                    boolean muted = (mAutomute && ss.level == 0) || ss.muted;
                    if (!isZenMuted && muted) {
                        ringerDrawable = mSysUIContext.getDrawable(
                            mSysUIR.drawable("ic_volume_ringer_mute"));
                        addAccessibilityDescription(mRingerIcon, RINGER_MODE_NORMAL,
                                mSysUIContext.getString(mSysUIR.string("volume_ringer_hint_unmute")));
                        mRingerIcon.setTag(Events.ICON_STATE_MUTE);
                    } else {
                        ringerDrawable = mSysUIContext.getDrawable(
                            mSysUIR.drawable("ic_volume_ringer"));
                        if (mController.hasVibrator()) {
                            addAccessibilityDescription(mRingerIcon, RINGER_MODE_NORMAL,
                                    mSysUIContext.getString(mSysUIR.string("volume_ringer_hint_vibrate")));
                        } else {
                            addAccessibilityDescription(mRingerIcon, RINGER_MODE_NORMAL,
                                    mSysUIContext.getString(mSysUIR.string("volume_ringer_hint_mute")));
                        }
                        mRingerIcon.setTag(Events.ICON_STATE_UNMUTE);
                    }
                    break;
            }
            mRingerIcon.setImageDrawable(ringerDrawable);
        }
    }

    private void addAccessibilityDescription(View view, int currState, String hintLabel) {
        int currStateResId;
        switch (currState) {
            case RINGER_MODE_SILENT:
                currStateResId = mSysUIR.string("volume_ringer_status_silent");
                break;
            case RINGER_MODE_VIBRATE:
                currStateResId = mSysUIR.string("volume_ringer_status_vibrate");
                break;
            case RINGER_MODE_NORMAL:
            default:
                currStateResId = mSysUIR.string("volume_ringer_status_normal");
        }

        view.setContentDescription(mSysUIContext.getString(currStateResId));
        view.setAccessibilityDelegate(new AccessibilityDelegate() {
            public void onInitializeAccessibilityNodeInfo(View host, AccessibilityNodeInfo info) {
                super.onInitializeAccessibilityNodeInfo(host, info);
                info.addAction(new AccessibilityNodeInfo.AccessibilityAction(
                                AccessibilityNodeInfo.ACTION_CLICK, hintLabel));
            }
        });
    }

    /**
     * Toggles enable state of views in a VolumeRow (not including seekbar or icon)
     * Hides/shows zen icon
     * @param enable whether to enable volume row views and hide dnd icon
     */
    private void enableVolumeRowViewsH(VolumeRow row, boolean enable) {
        boolean showDndIcon = !enable;
        row.dndIcon.setVisibility(showDndIcon ? VISIBLE : GONE);
    }

    /**
     * Toggles enable state of footer/ringer views
     * Hides/shows zen icon
     * @param enable whether to enable ringer views and hide dnd icon
     */
    private void enableRingerViewsH(boolean enable) {
        if (mRingerIcon != null) {
            mRingerIcon.setEnabled(enable);
        }
        if (mZenIcon != null) {
            mZenIcon.setVisibility(enable ? GONE : VISIBLE);
        }
    }

    private void trimObsoleteH() {
        if (D.BUG) Log.d(TAG, "trimObsoleteH");
        for (int i = mRows.size() - 1; i >= 0; i--) {
            final VolumeRow row = mRows.get(i);
            if (row.ss == null || !row.ss.dynamic) continue;
            if (!mDynamic.get(row.stream)) {
                removeRow(row);
                mConfigurableTexts.remove(row.header);
            }
        }
    }

    private void removeRow(VolumeRow volumeRow) {
        mRows.remove(volumeRow);
        mDialogRowsView.removeView(volumeRow.view);
    }

    protected void onStateChangedH(State state) {
        if (D.BUG) Log.d(TAG, "onStateChangedH() state: " + state.toString());
        if (mShowing && mState != null && state != null
                && mState.ringerModeInternal != -1
                && mState.ringerModeInternal != state.ringerModeInternal
                && state.ringerModeInternal == AudioManager.RINGER_MODE_VIBRATE) {
            mController.vibrate(VibrationEffect.get(VibrationEffect.EFFECT_HEAVY_CLICK));
        }

        mState = state;
        mDynamic.clear();
        // add any new dynamic rows
        for (int i = 0; i < state.states.size(); i++) {
            final int stream = state.states.keyAt(i);
            final StreamState ss = state.states.valueAt(i);
            if (!ss.dynamic) continue;
            mDynamic.put(stream, true);
            if (findRow(stream) == null) {
                addRow(stream, mSysUIR.drawable("ic_volume_remote"),
                        mSysUIR.drawable("ic_volume_remote_mute"), true,
                        false, true);
            }
        }

        if (mActiveStream != state.activeStream) {
            mPrevActiveStream = mActiveStream;
            mActiveStream = state.activeStream;
            VolumeRow activeRow = getActiveRow();
            updateRowsH(activeRow);
            if (mShowing) rescheduleTimeoutH();
        }
        for (VolumeRow row : mRows) {
            updateVolumeRowH(row);
        }
        updateRingerH();
    }

    CharSequence composeWindowTitle() {
        return mSysUIContext.getString(mSysUIR.string("volume_dialog_title"), getStreamLabelH(getActiveRow().ss));
    }

    private void updateVolumeRowH(VolumeRow row) {
        if (D.BUG) Log.i(TAG, "updateVolumeRowH s=" + row.stream);
        if (mState == null) return;
        final StreamState ss = mState.states.get(row.stream);
        if (ss == null) return;
        row.ss = ss;
        if (ss.level > ss.levelMin) {
            row.lastAudibleLevel = ss.level;
        }
        if (ss.level == row.requestedLevel) {
            row.requestedLevel = -1;
        }
        final boolean isA11yStream = row.stream == STREAM_ACCESSIBILITY;
        final boolean isRingStream = row.stream == AudioManager.STREAM_RING;
        final boolean isSystemStream = row.stream == AudioManager.STREAM_SYSTEM;
        final boolean isAlarmStream = row.stream == STREAM_ALARM;
        final boolean isMusicStream = row.stream == AudioManager.STREAM_MUSIC;
        final boolean isNotificationStream = row.stream == AudioManager.STREAM_NOTIFICATION;
        final boolean isVibrate = mState.ringerModeInternal == AudioManager.RINGER_MODE_VIBRATE;
        final boolean isRingVibrate = isRingStream && isVibrate;
        final boolean isRingSilent = isRingStream
                && mState.ringerModeInternal == AudioManager.RINGER_MODE_SILENT;
        final boolean isZenPriorityOnly = mState.zenMode == Global.ZEN_MODE_IMPORTANT_INTERRUPTIONS;
        final boolean isZenAlarms = mState.zenMode == Global.ZEN_MODE_ALARMS;
        final boolean isZenNone = mState.zenMode == Global.ZEN_MODE_NO_INTERRUPTIONS;
        final boolean zenMuted =
                isZenAlarms ? (isRingStream || isSystemStream || isNotificationStream)
                : isZenNone ? (isRingStream || isSystemStream || isAlarmStream || isMusicStream || isNotificationStream)
                : isZenPriorityOnly ? ((isAlarmStream && mState.disallowAlarms) ||
                        (isMusicStream && mState.disallowMedia) ||
                        (isRingStream && mState.disallowRinger) ||
                        (isSystemStream && mState.disallowSystem))
                : isVibrate ? isNotificationStream
                : false;

        // update slider max
        final int max = ss.levelMax * 100;
        final boolean maxChanged = max != row.slider.getMax();
        if (maxChanged) {
            row.slider.setMax(max);
        }
        // update slider min
        final int min = ss.levelMin * 100;
        if (min != row.slider.getMin()) {
            row.slider.setMin(min);
        }

        // update header text
        Utils.setText(row.header, getStreamLabelH(ss));
        row.slider.setContentDescription(row.header.getText());
        mConfigurableTexts.add(row.header, ss.name);

        // update icon
        final boolean iconEnabled = (mAutomute || ss.muteSupported) && !zenMuted;
        row.icon.setEnabled(iconEnabled);
        row.icon.setAlpha(iconEnabled ? 1 : 0.5f);
        final int iconRes =
                isRingVibrate ? mSysUIR.drawable("ic_volume_ringer_vibrate")
                        : isRingSilent || zenMuted ? row.iconMuteRes
                                : ss.routedToBluetooth
                                        ? isStreamMuted(ss) ? mSysUIR.drawable("ic_volume_media_bt_mute")
                                                : mSysUIR.drawable("ic_volume_media_bt")
                                        : isStreamMuted(ss) ? row.iconMuteRes : row.iconRes;
        Drawable iconResDrawable = mSysUIContext.getDrawable(iconRes);
        row.icon.setImageDrawable(iconResDrawable);
        row.iconState =
                iconRes == mSysUIR.drawable("ic_volume_ringer_vibrate") ? Events.ICON_STATE_VIBRATE
                : (iconRes == mSysUIR.drawable("ic_volume_media_bt_mute") || iconRes == row.iconMuteRes)
                        ? Events.ICON_STATE_MUTE
                : (iconRes == mSysUIR.drawable("ic_volume_media_bt") || iconRes == row.iconRes)
                        ? Events.ICON_STATE_UNMUTE
                : Events.ICON_STATE_UNKNOWN;
        if (iconEnabled) {
            if (isRingStream) {
                if (isRingVibrate) {
                    row.icon.setContentDescription(mSysUIContext.getString(
                            mSysUIR.string("volume_stream_content_description_unmute"),
                            getStreamLabelH(ss)));
                } else {
                    if (mController.hasVibrator()) {
                        row.icon.setContentDescription(mSysUIContext.getString(
                                mShowA11yStream
                                        ? mSysUIR.string("volume_stream_content_description_vibrate_a11y")
                                        : mSysUIR.string("volume_stream_content_description_vibrate"),
                                getStreamLabelH(ss)));
                    } else {
                        row.icon.setContentDescription(mSysUIContext.getString(
                                mShowA11yStream
                                        ? mSysUIR.string("volume_stream_content_description_mute_a11y")
                                        : mSysUIR.string("volume_stream_content_description_mute"),
                                getStreamLabelH(ss)));
                    }
                }
            } else if (isA11yStream) {
                row.icon.setContentDescription(getStreamLabelH(ss));
            } else {
                if (ss.muted || mAutomute && ss.level == 0) {
                   row.icon.setContentDescription(mSysUIContext.getString(
                           mSysUIR.string("volume_stream_content_description_unmute"),
                           getStreamLabelH(ss)));
                } else {
                    row.icon.setContentDescription(mSysUIContext.getString(
                            mShowA11yStream
                                    ? mSysUIR.string("volume_stream_content_description_mute_a11y")
                                    : mSysUIR.string("volume_stream_content_description_mute"),
                            getStreamLabelH(ss)));
                }
            }
        } else {
            row.icon.setContentDescription(getStreamLabelH(ss));
        }

        // ensure tracking is disabled if zenMuted
        if (zenMuted) {
            row.tracking = false;
        }
        enableVolumeRowViewsH(row, !zenMuted);

        // update slider
        final boolean enableSlider = !zenMuted;
        final int vlevel = row.ss.muted && (!isRingStream && !zenMuted) ? 0
                : row.ss.level;
        updateVolumeRowSliderH(row, enableSlider, vlevel, maxChanged);
    }

    private boolean isStreamMuted(final StreamState streamState) {
        return (mAutomute && streamState.level == streamState.levelMin) || streamState.muted;
    }

    private void updateVolumeRowTintH(VolumeRow row, boolean isActive) {
        if (isActive) {
            row.slider.requestFocus();
        }
        boolean useActiveColoring = isActive && row.slider.isEnabled();
        final ColorStateList tint = useActiveColoring
                ? Utils.getColorAccent(mSysUIContext)
                : Utils.getColorAttr(mSysUIContext, android.R.attr.colorForeground);
        final int alpha = useActiveColoring
                ? Color.alpha(tint.getDefaultColor())
                : getAlphaAttr(android.R.attr.secondaryContentAlpha);
        if (tint == row.cachedTint) return;
        row.slider.setProgressTintList(tint);
        row.slider.setThumbTintList(tint);
        row.slider.setProgressBackgroundTintList(tint);
        row.slider.setAlpha(((float) alpha) / 255);
        row.icon.setImageTintList(tint);
        row.icon.setImageAlpha(alpha);
        row.cachedTint = tint;
    }

    private void updateVolumeRowSliderH(VolumeRow row, boolean enable, int vlevel, boolean maxChanged) {
        row.slider.setEnabled(enable);
        updateVolumeRowTintH(row, row.stream == mActiveStream);
        if (row.tracking) {
            return;  // don't update if user is sliding
        }
        final int progress = row.slider.getProgress();
        final int level = getImpliedLevel(row.slider, progress);
        final boolean rowVisible = row.view.getVisibility() == VISIBLE;
        final boolean inGracePeriod = (SystemClock.uptimeMillis() - row.userAttempt)
                < USER_ATTEMPT_GRACE_PERIOD;
        mHandler.removeMessages(H.RECHECK, row);
        if (mShowing && rowVisible && inGracePeriod) {
            if (D.BUG) Log.d(TAG, "inGracePeriod");
            mHandler.sendMessageAtTime(mHandler.obtainMessage(H.RECHECK, row),
                    row.userAttempt + USER_ATTEMPT_GRACE_PERIOD);
            return;  // don't update if visible and in grace period
        }
        if (vlevel == level) {
            if (mShowing && rowVisible) {
                return;  // don't clamp if visible
            }
        }
        final int newProgress = vlevel * 100;
        if (progress != newProgress || maxChanged) {
            if (mShowing && rowVisible) {
                // animate!
                if (row.anim != null && row.anim.isRunning()
                        && row.animTargetProgress == newProgress) {
                    return;  // already animating to the target progress
                }
                // start/update animation
                if (row.anim == null) {
                    row.anim = ObjectAnimator.ofInt(row.slider, "progress", progress, newProgress);
                    row.anim.setInterpolator(new DecelerateInterpolator());
                } else {
                    row.anim.cancel();
                    row.anim.setIntValues(progress, newProgress);
                }
                row.animTargetProgress = newProgress;
                row.anim.setDuration(UPDATE_ANIMATION_DURATION);
                row.anim.start();
            } else {
                // update slider directly to clamped value
                if (row.anim != null) {
                    row.anim.cancel();
                }
                row.slider.setProgress(newProgress, true);
            }
        }
    }

    private void recheckH(VolumeRow row) {
        if (row == null) {
            if (D.BUG) Log.d(TAG, "recheckH ALL");
            trimObsoleteH();
            for (VolumeRow r : mRows) {
                updateVolumeRowH(r);
            }
        } else {
            if (D.BUG) Log.d(TAG, "recheckH " + row.stream);
            updateVolumeRowH(row);
        }
    }

    private void setStreamImportantH(int stream, boolean important) {
        for (VolumeRow row : mRows) {
            if (row.stream == stream) {
                row.important = important;
                return;
            }
        }
    }

    private void showSafetyWarningH(int flags) {
        if ((flags & (AudioManager.FLAG_SHOW_UI | AudioManager.FLAG_SHOW_UI_WARNINGS)) != 0
                || mShowing) {
            synchronized (mSafetyWarningLock) {
                if (mSafetyWarning != null) {
                    return;
                }
                mSafetyWarning = new SafetyWarningDialog(mContext, mController.getAudioManager()) {
                    @Override
                    protected void cleanUp() {
                        synchronized (mSafetyWarningLock) {
                            mSafetyWarning = null;
                        }
                        recheckH(null);
                    }
                };
                mSafetyWarning.show();
            }
            recheckH(null);
        }
        rescheduleTimeoutH();
    }

    private String getStreamLabelH(StreamState ss) {
        if (ss == null) {
            return "";
        }
        if (ss.remoteLabel != null) {
            return ss.remoteLabel;
        }
        try {
            return mSysUIContext.getString(ss.name);
        } catch (Resources.NotFoundException e) {
            Slog.e(TAG, "Can't find translation for stream " + ss);
            return "";
        }
    }

    private Runnable getSinglePressFor(ImageButton button) {
        return () -> {
            if (button != null) {
                button.setPressed(true);
                button.postOnAnimationDelayed(getSingleUnpressFor(button), 200);
            }
        };
    }

    private Runnable getSingleUnpressFor(ImageButton button) {
        return () -> {
            if (button != null) {
                button.setPressed(false);
            }
        };
    }

    private final VolumeDialogController.Callbacks mControllerCallbackH
            = new VolumeDialogController.Callbacks() {
        @Override
        public void onShowRequested(int reason) {
            showH(reason);
        }

        @Override
        public void onDismissRequested(int reason) {
            dismissH(reason);
        }

        @Override
        public void onScreenOff() {
            dismissH(Events.DISMISS_REASON_SCREEN_OFF);
        }

        @Override
        public void onStateChanged(State state) {
            onStateChangedH(state);
        }

        @Override
        public void onLayoutDirectionChanged(int layoutDirection) {
            mDialogView.setLayoutDirection(layoutDirection);
        }

        @Override
        public void onConfigurationChanged() {
            if (mDialog.isShown()) mWindowManager.removeViewImmediate(mDialog);
            mConfigChanged = true;
        }

        @Override
        public void onShowVibrateHint() {
            if (mSilentMode) {
                mController.setRingerMode(AudioManager.RINGER_MODE_SILENT, false);
            }
        }

        @Override
        public void onShowSilentHint() {
            if (mSilentMode) {
                mController.setRingerMode(AudioManager.RINGER_MODE_NORMAL, false);
            }
        }

        @Override
        public void onShowSafetyWarning(int flags) {
            showSafetyWarningH(flags);
        }

        @Override
        public void onAccessibilityModeChanged(Boolean showA11yStream) {
            mShowA11yStream = showA11yStream == null ? false : showA11yStream;
            VolumeRow activeRow = getActiveRow();
            if (!mShowA11yStream && STREAM_ACCESSIBILITY == activeRow.stream) {
                dismissH(Events.DISMISS_STREAM_GONE);
            } else {
                updateRowsH(activeRow);
            }

        }

        @Override
        public void onCaptionComponentStateChanged(
                Boolean isComponentEnabled, Boolean fromTooltip) {
            updateODICaptionsH(isComponentEnabled, fromTooltip);
        }
    };

    private final class H extends Handler {
        private static final int SHOW = 1;
        private static final int DISMISS = 2;
        private static final int RECHECK = 3;
        private static final int RECHECK_ALL = 4;
        private static final int SET_STREAM_IMPORTANT = 5;
        private static final int RESCHEDULE_TIMEOUT = 6;
        private static final int STATE_CHANGED = 7;

        public H() {
            super(Looper.getMainLooper());
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SHOW: showH(msg.arg1); break;
                case DISMISS: dismissH(msg.arg1); break;
                case RECHECK: recheckH((VolumeRow) msg.obj); break;
                case RECHECK_ALL: recheckH(null); break;
                case SET_STREAM_IMPORTANT: setStreamImportantH(msg.arg1, msg.arg2 != 0); break;
                case RESCHEDULE_TIMEOUT: rescheduleTimeoutH(); break;
                case STATE_CHANGED: onStateChangedH(mState); break;
            }
        }
    }

    private final class VolumeSeekBarChangeListener implements OnSeekBarChangeListener {
        private final VolumeRow mRow;

        private VolumeSeekBarChangeListener(VolumeRow row) {
            mRow = row;
        }

        @Override
        public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
            if (mRow.ss == null) return;
            if (D.BUG) Log.d(TAG, AudioSystem.streamToString(mRow.stream)
                    + " onProgressChanged " + progress + " fromUser=" + fromUser);
            rescheduleTimeoutH();
            if (!fromUser) return;
            if (mRow.ss.levelMin > 0) {
                final int minProgress = mRow.ss.levelMin * 100;
                if (progress < minProgress) {
                    seekBar.setProgress(minProgress);
                    progress = minProgress;
                }
            }
            final int userLevel = getImpliedLevel(seekBar, progress);
            if (mRow.ss.level != userLevel || mRow.ss.muted && userLevel > 0) {
                mRow.userAttempt = SystemClock.uptimeMillis();
                if (mRow.requestedLevel != userLevel) {
                    mController.setActiveStream(mRow.stream);
                    mController.setStreamVolume(mRow.stream, userLevel);
                    mRow.requestedLevel = userLevel;
                    Events.writeEvent(Events.EVENT_TOUCH_LEVEL_CHANGED, mRow.stream,
                            userLevel);
                }
            }
        }

        @Override
        public void onStartTrackingTouch(SeekBar seekBar) {
            if (D.BUG) Log.d(TAG, "onStartTrackingTouch"+ " " + mRow.stream);
            mController.setActiveStream(mRow.stream);
            mRow.tracking = true;
            if(mPanelMode == PanelMode.MINI) {
                mPanelMode = PanelMode.COLLAPSED;
                updatePanelOnMode();
            }
        }

        @Override
        public void onStopTrackingTouch(SeekBar seekBar) {
            if (D.BUG) Log.d(TAG, "onStopTrackingTouch"+ " " + mRow.stream);
            mRow.tracking = false;
            mRow.userAttempt = SystemClock.uptimeMillis();
            final int userLevel = getImpliedLevel(seekBar, seekBar.getProgress());
            Events.writeEvent(Events.EVENT_TOUCH_LEVEL_DONE, mRow.stream, userLevel);
            if (mRow.ss.level != userLevel) {
                mHandler.sendMessageDelayed(mHandler.obtainMessage(H.RECHECK, mRow),
                        USER_ATTEMPT_GRACE_PERIOD);
            }
        }
    }

    private final class Accessibility extends AccessibilityDelegate {
        public void init() {
            mDialogView.setAccessibilityDelegate(this);
        }

        @Override
        public boolean dispatchPopulateAccessibilityEvent(View host, AccessibilityEvent event) {
            // Activities populate their title here. Follow that example.
            event.getText().add(composeWindowTitle());
            return true;
        }

        @Override
        public boolean onRequestSendAccessibilityEvent(ViewGroup host, View child,
                AccessibilityEvent event) {
            rescheduleTimeoutH();
            return super.onRequestSendAccessibilityEvent(host, child, event);
        }
    }

    private boolean isAudioPanelOnLeftSide() {
        return mPanelOnLeftSide;
    }

    private static class VolumeRow {
        private View view;
        private TextView header;
        private ImageButton icon;
        private SeekBar slider;
        private int stream;
        private StreamState ss;
        private long userAttempt;  // last user-driven slider change
        private boolean tracking;  // tracking slider touch
        private int requestedLevel = -1;  // pending user-requested level via progress changed
        private int iconRes;
        private int iconMuteRes;
        private boolean important;
        private boolean defaultStream;
        private ColorStateList cachedTint;
        private int iconState;  // from Events
        private ObjectAnimator anim;  // slider progress animation for non-touch-related updates
        private int animTargetProgress;
        private int lastAudibleLevel = 2;
        private FrameLayout dndIcon;
    }

    private enum PanelMode {
        MINI,
        COLLAPSED,
        EXPANDED,
    }
}
