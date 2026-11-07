import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { apiClient } from '../../api/client';
import { Card } from '../../components/Card';
import { Input } from '../../components/Input';
import { Button } from '../../components/Button';
import { Badge } from '../../components/Badge';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const DriverHomeScreen = ({ navigation }: any) => {
  const { user, switchRole, refreshProfile } = useAuth();
  const [vehicles, setVehicles] = useState<any[]>([]);
  const [selectedVehicleId, setSelectedVehicleId] = useState<string>('');
  
  // Create Ride Form state
  const [startText, setStartText] = useState('Meltem KYK Yurdu');
  const [destText, setDestText] = useState('Antalya Bilim Üniversitesi Ana Kampüs');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    fetchVehicles();
  }, []);

  const fetchVehicles = async () => {
    try {
      const res: any = await apiClient.get('/vehicles/me');
      const list = res.data || [];
      setVehicles(list);
      if (list.length > 0) {
        setSelectedVehicleId(list[0].id);
      }
    } catch (e) {
      console.warn('Failed to fetch vehicles', e);
    }
  };

  const handleCreateRide = async () => {
    if (!selectedVehicleId) {
      Alert.alert('Araç Eksik', 'Yolculuk başlatmak için öncelikle bir araç eklemelisiniz.');
      return;
    }

    setIsSubmitting(true);
    try {
      await apiClient.post('/rides', {
        arac_id: selectedVehicleId,
        baslangic_lat: 36.8848,
        baslangic_lng: 30.7040,
        baslangic_metni: startText,
        varis_lat: 36.9856,
        varis_lng: 30.6589,
        varis_metni: destText,
        kalkis_zamani: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
      });

      Alert.alert('İlan Başarıyla Açıldı 🚗', 'Yolcular harita üzerinde ilanınızı görmeye başladı.');
      refreshProfile();
    } catch (error: any) {
      Alert.alert('Hata', error.message || 'İlan oluşturulamadı.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Role Switcher Bar */}
      <View style={styles.topHeader}>
        <View style={styles.roleToggleBox}>
          <TouchableOpacity
            style={styles.roleBtn}
            onPress={() => switchRole('yolcu')}
          >
            <Text style={styles.roleText}>🚶‍♂️ Yolcu Modu</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.roleBtn, styles.roleBtnActive]}
            onPress={() => switchRole('sofor')}
          >
            <Text style={styles.roleTextActive}>🚗 Şoför Modu</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Driver Reward Status Card */}
      <Card style={styles.rewardCard}>
        <View style={styles.rewardHeader}>
          <View>
            <Text style={styles.rewardTitle}>🏆 Şoför Ayrıcalık Durumunuz</Text>
            <Badge level={user?.driver_points?.rozet_seviyesi || 'baslangic'} />
          </View>
          <View style={styles.pointsBadge}>
            <Text style={styles.pointsNumber}>{user?.driver_points?.toplam_puan || 0}</Text>
            <Text style={styles.pointsLabel}>Puan</Text>
          </View>
        </View>

        <View style={styles.progressBox}>
          <Text style={styles.progressText}>
            Yemek Kartı Kredisi Hak Kazanımı: <Text style={{ color: colors.success, fontWeight: '800' }}>250 TL (Aptal Yolculuklar)</Text>
          </Text>
        </View>
      </Card>

      {/* QR Scanner Trigger Button */}
      <Button
        title="📷 Yolcu QR Kodunu Okut (Biniş Onayı)"
        onPress={() => navigation.navigate('QrScanner')}
        style={{ marginBottom: spacing.md }}
      />

      {/* Create New Ride Section */}
      <Card>
        <Text style={styles.cardTitle}>Yeni Yolculuk İlanı Oluştur 🚗</Text>

        <Input
          label="Başlangıç Noktası"
          value={startText}
          onChangeText={setStartText}
        />

        <Input
          label="Varış Noktası"
          value={destText}
          onChangeText={setDestText}
        />

        <Text style={styles.label}>Kullanılacak Araç</Text>
        {vehicles.length === 0 ? (
          <TouchableOpacity
            style={styles.addVehicleBox}
            onPress={() => navigation.navigate('VehicleManagement')}
          >
            <Text style={styles.addVehicleText}>+ Araç Bilgisi Ekle (Plaka / Kapasite)</Text>
          </TouchableOpacity>
        ) : (
          <View style={styles.vehicleSelectBox}>
            {vehicles.map((v) => (
              <TouchableOpacity
                key={v.id}
                style={[
                  styles.vehicleOption,
                  selectedVehicleId === v.id && styles.vehicleOptionActive,
                ]}
                onPress={() => setSelectedVehicleId(v.id)}
              >
                <Text
                  style={[
                    styles.vehicleOptionText,
                    selectedVehicleId === v.id && styles.vehicleOptionTextActive,
                  ]}
                >
                  {v.marka_model} — ({v.plaka}) — {v.kapasite} Koltuk
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        <Button
          title="Yolculuğu Yayına Al (+10 Puan / Yolcu)"
          onPress={handleCreateRide}
          loading={isSubmitting}
          style={{ marginTop: spacing.md }}
        />
      </Card>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: spacing.md,
  },
  topHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: spacing.md,
    marginTop: spacing.sm,
  },
  roleToggleBox: {
    flexDirection: 'row',
    backgroundColor: colors.surfaceLight,
    borderRadius: borderRadius.full,
    padding: 3,
  },
  roleBtn: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
  },
  roleBtnActive: {
    backgroundColor: colors.primary,
  },
  roleText: {
    color: colors.textMuted,
    fontWeight: '600',
    fontSize: fontSizes.xs,
  },
  roleTextActive: {
    color: '#FFF',
    fontWeight: '700',
    fontSize: fontSizes.xs,
  },
  rewardCard: {
    borderColor: colors.accent,
  },
  rewardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  rewardTitle: {
    color: colors.text,
    fontWeight: '700',
    fontSize: fontSizes.sm,
    marginBottom: spacing.xs,
  },
  pointsBadge: {
    alignItems: 'center',
    backgroundColor: 'rgba(245, 158, 11, 0.15)',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.md,
    borderWidth: 1,
    borderColor: colors.accent,
  },
  pointsNumber: {
    color: colors.accent,
    fontSize: fontSizes.xl,
    fontWeight: '900',
  },
  pointsLabel: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
  },
  progressBox: {
    marginTop: spacing.md,
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  progressText: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
  },
  cardTitle: {
    color: colors.text,
    fontSize: fontSizes.md,
    fontWeight: '700',
    marginBottom: spacing.md,
  },
  label: {
    color: colors.textSecondary,
    fontSize: fontSizes.sm,
    fontWeight: '600',
    marginBottom: spacing.xs,
  },
  addVehicleBox: {
    backgroundColor: colors.surfaceLight,
    padding: spacing.md,
    borderRadius: borderRadius.md,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.primary,
    borderStyle: 'dashed',
  },
  addVehicleText: {
    color: colors.primary,
    fontWeight: '600',
    fontSize: fontSizes.sm,
  },
  vehicleSelectBox: {
    marginBottom: spacing.sm,
  },
  vehicleOption: {
    backgroundColor: colors.surfaceLight,
    padding: spacing.md,
    borderRadius: borderRadius.md,
    marginBottom: spacing.xs,
    borderWidth: 1,
    borderColor: colors.border,
  },
  vehicleOptionActive: {
    borderColor: colors.primary,
    backgroundColor: 'rgba(6, 182, 212, 0.1)',
  },
  vehicleOptionText: {
    color: colors.textSecondary,
    fontSize: fontSizes.sm,
  },
  vehicleOptionTextActive: {
    color: colors.primary,
    fontWeight: '700',
  },
});
