import { useEffect, useState } from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, Alert, Image } from 'react-native';
import { Text, Button, Card, Divider, ActivityIndicator, Portal, Dialog, TextInput } from 'react-native-paper';
import { Ionicons } from '@expo/vector-icons';
import { useRouter, useLocalSearchParams } from 'expo-router';
import * as ImagePicker from 'expo-image-picker';
import { useBookingStore } from '../../../src/store/bookingStore';
import { COLORS, iOS, TYPOGRAPHY } from '../../../src/theme/theme';

export default function BookingDetailScreen() {
  const { id } = useLocalSearchParams();
  const router = useRouter();
  const { bookingDetail, fetchBookingDetail, updateStatus, isLoading } = useBookingStore();
  const [showOtpDialog, setShowOtpDialog] = useState(false);
  const [otp, setOtp] = useState('');
  const [evidencePhotos, setEvidencePhotos] = useState([]);
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    if (id) fetchBookingDetail(id);
  }, [id]);

  const booking = bookingDetail;
  if (!booking) {
    return (
      <View style={styles.loader}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={styles.loaderText}>Loading booking details...</Text>
      </View>
    );
  }

  const status = booking.booking_status;
  const serviceAddress = booking.service_address;

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending': return COLORS.warning;
      case 'accepted': return COLORS.primary;
      case 'ongoing': return COLORS.purple;
      case 'completed': return COLORS.success;
      case 'canceled': return COLORS.error;
      default: return COLORS.grey;
    }
  };

  const getStatusBgColor = (status) => {
    switch (status) {
      case 'pending': return COLORS.warningAlpha;
      case 'accepted': return COLORS.primaryAlpha;
      case 'ongoing': return COLORS.purpleAlpha;
      case 'completed': return COLORS.successAlpha;
      case 'canceled': return COLORS.errorAlpha;
      default: return COLORS.greyLight;
    }
  };

  const handleStatusUpdate = async (newStatus) => {
    if (newStatus === 'completed' && evidencePhotos.length === 0) {
      setShowOtpDialog(true);
      return;
    }
    setActionLoading(true);
    const result = await updateStatus(booking.id, newStatus, otp, evidencePhotos);
    setActionLoading(false);
    if (result.success) {
      Alert.alert('Success', `Booking ${newStatus} successfully`);
    } else {
      Alert.alert('Error', result.message || 'Failed to update');
    }
  };

  const handleOtpSubmit = async () => {
    setShowOtpDialog(false);
    setActionLoading(true);
    const result = await updateStatus(booking.id, 'completed', otp, evidencePhotos);
    setActionLoading(false);
    if (result.success) {
      Alert.alert('Success', 'Booking completed successfully');
    } else {
      Alert.alert('Error', result.message || 'Failed to update');
    }
  };

  const pickImages = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsMultipleSelection: true,
      quality: 0.8,
    });
    if (!result.canceled) {
      setEvidencePhotos([...evidencePhotos, ...result.assets]);
    }
  };

  const removeImage = (index) => {
    setEvidencePhotos(evidencePhotos.filter((_, i) => i !== index));
  };

  const openNavigation = () => {
    if (serviceAddress?.lat && serviceAddress?.lon) {
      router.push(`/(main)/navigation?destLat=${serviceAddress.lat}&destLng=${serviceAddress.lon}&address=${encodeURIComponent(serviceAddress.address || '')}&bookingId=${booking.id}`);
    } else {
      Alert.alert('Error', 'Service address not available');
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer} showsVerticalScrollIndicator={false}>
      {/* Header */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
          <Ionicons name="chevron-back" size={24} color={COLORS.textPrimary} />
        </TouchableOpacity>
        <View style={styles.headerCenter}>
          <Text style={styles.title}>Booking #{booking.readable_id}</Text>
          <View style={[styles.statusBadge, { backgroundColor: getStatusBgColor(status) }]}>
            <Text style={[styles.statusText, { color: getStatusColor(status) }]}>
              {status?.toUpperCase()}
            </Text>
          </View>
        </View>
        <View style={styles.headerRight} />
      </View>

      {/* Customer Info */}
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.cardHeader}>
            <View style={[styles.cardIconBg, { backgroundColor: COLORS.primaryAlpha }]}>
              <Ionicons name="person" size={20} color={COLORS.primary} />
            </View>
            <Text style={styles.cardTitle}>Customer Information</Text>
          </View>
          <Divider style={styles.divider} />
          <View style={styles.infoRow}>
            <Ionicons name="person-outline" size={18} color={COLORS.textSecondary} />
            <Text style={styles.infoLabel}>Name:</Text>
            <Text style={styles.infoValue}>{booking.customer?.fName || 'N/A'}</Text>
          </View>
          <View style={styles.infoRow}>
            <Ionicons name="call-outline" size={18} color={COLORS.textSecondary} />
            <Text style={styles.infoLabel}>Phone:</Text>
            <Text style={styles.infoValue}>{booking.customer?.phone || 'N/A'}</Text>
          </View>
        </Card.Content>
      </Card>

      {/* Service Address */}
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.cardHeader}>
            <View style={[styles.cardIconBg, { backgroundColor: COLORS.errorAlpha }]}>
              <Ionicons name="location" size={20} color={COLORS.error} />
            </View>
            <Text style={styles.cardTitle}>Service Location</Text>
          </View>
          <Divider style={styles.divider} />
          <View style={styles.addressRow}>
            <Ionicons name="location-outline" size={20} color={COLORS.textSecondary} />
            <Text style={styles.addressText} numberOfLines={3}>
              {serviceAddress?.address || 'Address not available'}
            </Text>
          </View>
          {serviceAddress?.lat && serviceAddress?.lon && (
            <Button
              mode="contained"
              icon="navigation"
              onPress={openNavigation}
              style={styles.navButton}
              contentStyle={styles.navButtonContent}
              labelStyle={styles.navButtonLabel}
              buttonColor={COLORS.primary}
            >
              Navigate to Client
            </Button>
          )}
        </Card.Content>
      </Card>

      {/* Service Details */}
      <Card style={styles.card}>
        <Card.Content>
          <View style={styles.cardHeader}>
            <View style={[styles.cardIconBg, { backgroundColor: COLORS.successAlpha }]}>
              <Ionicons name="construct" size={20} color={COLORS.success} />
            </View>
            <Text style={styles.cardTitle}>Service Details</Text>
          </View>
          <Divider style={styles.divider} />
          {booking.booking_details?.map((item, index) => (
            <View key={index} style={styles.serviceItem}>
              <View style={styles.serviceInfo}>
                <Text style={styles.serviceName}>{item.service_name || 'Service'}</Text>
                <Text style={styles.serviceVariant}>{item.variant_key || ''}</Text>
              </View>
              <View style={styles.serviceMeta}>
                <Text style={styles.serviceQty}>Qty: {item.quantity || 1}</Text>
                <Text style={styles.serviceCost}>${item.total_cost || 0}</Text>
              </View>
            </View>
          ))}
          <Divider style={styles.divider} />
          <View style={styles.totalRow}>
            <Text style={styles.totalLabel}>Total Amount</Text>
            <Text style={styles.totalValue}>${booking.total_booking_amount || 0}</Text>
          </View>
        </Card.Content>
      </Card>

      {/* Booking OTP */}
      {booking.booking_otp && (status === 'accepted' || status === 'ongoing') && (
        <Card style={[styles.card, styles.otpCard]}>
          <Card.Content>
            <View style={styles.otpRow}>
              <View style={[styles.otpIconBg, { backgroundColor: COLORS.warningAlpha }]}>
                <Ionicons name="key" size={24} color={COLORS.warning} />
              </View>
              <View style={styles.otpTextContainer}>
                <Text style={styles.otpTitle}>Booking OTP</Text>
                <Text style={styles.otpCode}>{booking.booking_otp}</Text>
              </View>
            </View>
          </Card.Content>
        </Card>
      )}

      {/* Photo Evidence */}
      {status === 'completed' && (
        <Card style={styles.card}>
          <Card.Content>
            <View style={styles.cardHeader}>
              <View style={[styles.cardIconBg, { backgroundColor: COLORS.infoAlpha }]}>
                <Ionicons name="camera" size={20} color={COLORS.info} />
              </View>
              <Text style={styles.cardTitle}>Photo Evidence</Text>
            </View>
            <Divider style={styles.divider} />
            <View style={styles.photoGrid}>
              {evidencePhotos.map((photo, index) => (
                <View key={index} style={styles.photoContainer}>
                  <Image source={{ uri: photo.uri }} style={styles.photo} />
                  <TouchableOpacity
                    style={styles.removePhoto}
                    onPress={() => removeImage(index)}
                  >
                    <View style={styles.removePhotoBg}>
                      <Ionicons name="close" size={16} color={COLORS.white} />
                    </View>
                  </TouchableOpacity>
                </View>
              ))}
              <TouchableOpacity style={styles.addPhotoBtn} onPress={pickImages}>
                <Ionicons name="add" size={28} color={COLORS.primary} />
                <Text style={styles.addPhotoText}>Add Photo</Text>
              </TouchableOpacity>
            </View>
          </Card.Content>
        </Card>
      )}

      {/* Action Buttons */}
      <View style={styles.actions}>
        {status === 'pending' && (
          <Button
            mode="contained"
            onPress={() => handleStatusUpdate('accepted')}
            loading={actionLoading}
            style={styles.actionBtn}
            contentStyle={styles.actionBtnContent}
            labelStyle={styles.actionBtnLabel}
            buttonColor={COLORS.primary}
            icon="checkmark"
          >
            Accept Booking
          </Button>
        )}

        {status === 'accepted' && (
          <>
            <Button
              mode="contained"
              onPress={openNavigation}
              icon="navigation"
              style={styles.actionBtn}
              contentStyle={styles.actionBtnContent}
              labelStyle={styles.actionBtnLabel}
              buttonColor={COLORS.primary}
            >
              Navigate to Client
            </Button>
            <Button
              mode="contained"
              onPress={() => handleStatusUpdate('ongoing')}
              loading={actionLoading}
              style={styles.actionBtn}
              contentStyle={styles.actionBtnContent}
              labelStyle={styles.actionBtnLabel}
              buttonColor={COLORS.purple}
              icon="play"
            >
              Start Service
            </Button>
          </>
        )}

        {status === 'ongoing' && (
          <Button
            mode="contained"
            onPress={() => handleStatusUpdate('completed')}
            loading={actionLoading}
            style={styles.actionBtn}
            contentStyle={styles.actionBtnContent}
            labelStyle={styles.actionBtnLabel}
            buttonColor={COLORS.success}
            icon="checkmark-done"
          >
            Complete Service
          </Button>
        )}
      </View>

      {/* OTP Dialog */}
      <Portal>
        <Dialog visible={showOtpDialog} onDismiss={() => setShowOtpDialog(false)} style={styles.dialog}>
          <Dialog.Title>Enter OTP</Dialog.Title>
          <Dialog.Content>
            <Text style={styles.dialogText}>Please enter the OTP to complete this booking.</Text>
            <TextInput
              mode="outlined"
              value={otp}
              onChangeText={setOtp}
              keyboardType="numeric"
              maxLength={6}
              style={styles.otpInput}
              outlineStyle={styles.otpInputOutline}
              theme={{ colors: { primary: COLORS.primary } }}
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setShowOtpDialog(false)}>Cancel</Button>
            <Button onPress={handleOtpSubmit} loading={actionLoading}>Submit</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  contentContainer: {
    paddingHorizontal: iOS.screenPadding.horizontal,
    paddingTop: iOS.spacing.xxxxxl,
    paddingBottom: iOS.spacing.xxxxxl,
  },
  loader: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: iOS.spacing.md,
  },
  loaderText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: iOS.spacing.xl,
  },
  backBtn: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    backgroundColor: COLORS.surface,
    justifyContent: 'center',
    alignItems: 'center',
    ...iOS.shadowSmall,
  },
  headerCenter: {
    flex: 1,
    alignItems: 'center',
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  statusBadge: {
    paddingHorizontal: iOS.spacing.md,
    paddingVertical: iOS.spacing.xs,
    borderRadius: iOS.borderRadius.base,
    marginTop: iOS.spacing.xs,
  },
  statusText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  headerRight: {
    width: 40,
  },
  card: {
    marginBottom: iOS.spacing.lg,
    borderRadius: iOS.borderRadius.xl,
    backgroundColor: COLORS.surface,
    ...iOS.shadowSmall,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.md,
    marginBottom: iOS.spacing.md,
  },
  cardIconBg: {
    width: 40,
    height: 40,
    borderRadius: iOS.borderRadius.lg,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  divider: {
    backgroundColor: COLORS.separatorLight,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: iOS.spacing.md,
    gap: iOS.spacing.sm,
  },
  infoLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    width: 60,
  },
  infoValue: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    flex: 1,
  },
  addressRow: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: iOS.spacing.sm,
    marginBottom: iOS.spacing.lg,
  },
  addressText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textPrimary,
    flex: 1,
    lineHeight: TYPOGRAPHY.lineHeight.relaxed,
  },
  navButton: {
    borderRadius: iOS.borderRadius.lg,
    marginTop: iOS.spacing.sm,
  },
  navButtonContent: {
    height: iOS.height.button,
  },
  navButtonLabel: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  serviceItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: iOS.spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.separatorLight,
  },
  serviceInfo: {
    flex: 1,
  },
  serviceName: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.textPrimary,
    marginBottom: iOS.spacing.xs,
  },
  serviceVariant: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
  },
  serviceMeta: {
    alignItems: 'flex-end',
  },
  serviceQty: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.xs,
  },
  serviceCost: {
    fontSize: TYPOGRAPHY.fontSize.base,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.primary,
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: iOS.spacing.md,
    paddingTop: iOS.spacing.md,
  },
  totalLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.textPrimary,
  },
  totalValue: {
    fontSize: TYPOGRAPHY.fontSize.xxl,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.primary,
  },
  otpCard: {
    backgroundColor: COLORS.warningLight,
    borderWidth: 1,
    borderColor: COLORS.warning,
  },
  otpRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: iOS.spacing.lg,
  },
  otpIconBg: {
    width: 56,
    height: 56,
    borderRadius: iOS.borderRadius.xl,
    justifyContent: 'center',
    alignItems: 'center',
  },
  otpTextContainer: {
    flex: 1,
  },
  otpTitle: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.xs,
  },
  otpCode: {
    fontSize: TYPOGRAPHY.fontSize.massive,
    fontWeight: TYPOGRAPHY.fontWeight.heavy,
    color: COLORS.warning,
    letterSpacing: 6,
  },
  photoGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: iOS.spacing.md,
  },
  photoContainer: {
    position: 'relative',
  },
  photo: {
    width: 80,
    height: 80,
    borderRadius: iOS.borderRadius.lg,
  },
  removePhoto: {
    position: 'absolute',
    top: -8,
    right: -8,
  },
  removePhotoBg: {
    width: 24,
    height: 24,
    borderRadius: iOS.borderRadius.full,
    backgroundColor: COLORS.error,
    justifyContent: 'center',
    alignItems: 'center',
  },
  addPhotoBtn: {
    width: 80,
    height: 80,
    borderRadius: iOS.borderRadius.lg,
    borderWidth: 2,
    borderStyle: 'dashed',
    borderColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.primaryAlpha,
  },
  addPhotoText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.primary,
    marginTop: iOS.spacing.xs,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  actions: {
    gap: iOS.spacing.md,
    marginTop: iOS.spacing.lg,
  },
  actionBtn: {
    borderRadius: iOS.borderRadius.lg,
    height: iOS.height.button,
    ...iOS.shadowMedium,
  },
  actionBtnContent: {
    height: iOS.height.button,
  },
  actionBtnLabel: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
  },
  dialog: {
    borderRadius: iOS.borderRadius.xl,
  },
  dialogText: {
    fontSize: TYPOGRAPHY.fontSize.base,
    color: COLORS.textSecondary,
    marginBottom: iOS.spacing.lg,
  },
  otpInput: {
    marginBottom: iOS.spacing.md,
  },
  otpInputOutline: {
    borderRadius: iOS.borderRadius.lg,
  },
});