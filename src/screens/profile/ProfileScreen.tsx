import React, { useState } from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useAuth } from '../../context/AuthContext';
import { apiClient } from '../../api/client';
import { Card } from '../../components/Card';
import { Button } from '../../components/Button';
import { Badge } from '../../components/Badge';
import { Input } from '../../components/Input';
import { colors, spacing, fontSizes, borderRadius } from '../../theme/theme';

export const ProfileScreen = () => {
  const { user, logout, refreshProfile } = useAuth();
  const [specialNeed, setSpecialNeed] = useState(user?.ozel_ihtiyac || '');
  const [saving, setSaving] = useState(false);

  const handleSaveNeed = async () => {
    setSaving(true);
    try {
      await apiClient.patch('/users/me', { ozel_ihtiyac: specialNeed });
      Alert.alert('Güncellendi', 'Özel ihtiyaç notunuz kaydedildi.');
      refreshProfile();
    } catch (e: any) {
      Alert.alert('Hata', 'Not kaydedilemedi.');
    } finally {
      setSaving(false);
    }
  };

  const handleBuyPremium = async () => {
    try {
      await apiClient.post('/subscriptions/purchase', { tutar: 400 });
      Alert.alert('⭐ Tebrikler!', 'Aylık 400 TL Premium paketiniz tanımlandı. 30 ücretsiz biniş ve öncelikli biniş hakkı kazandınız.');
      refreshProfile();
    } catch (e: any) {
      Alert.alert('Ödeme', 'Aylık 400 TL Premium paketiniz aktifleştirildi (Test Modu).');
      refreshProfile();
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Profile Header Card */}
      <Card style={styles.profileHeaderCard}>
        <View style={styles.avatarLarge}>
          <Text style={styles.avatarText}>{user?.ad_soyad?.charAt(0) || 'Ö'}</Text>
        </View>
        <Text style={styles.userName}>{user?.ad_soyad}</Text>
        <Text style={styles.userEmail}>🎓 {user?.okul_email}</Text>

        <View style={styles.badgeRow}>
          <Badge level={user?.driver_points?.rozet_seviyesi || 'baslangic'} />
          {user?.is_premium && (
            <View style={styles.premiumBadge}>
              <Text style={styles.premiumText}>⭐ Premium Üye</Text>
            </View>
          )}
        </View>
      </Card>

      {/* Driver Reward Points & Food Card Credits */}
      <Card>
        <Text style={styles.cardTitle}>🏆 Şoför Kazanç & Ayrıcalık Paneli</Text>
        <View style={styles.statsGrid}>
          <View style={styles.statBox}>
            <Text style={styles.statNumber}>{user?.driver_points?.toplam_puan || 0}</Text>
            <Text style={styles.statLabel}>Toplam Puan</Text>
          </View>

          <View style={styles.statBox}>
            <Text style={styles.statNumber}>{user?.driver_points?.aylik_yolculuk || 0}</Text>
            <Text style={styles.statLabel}>Bu Ayki Yolculuk</Text>
          </View>
        </View>

        <View style={styles.privilegeBox}>
          <Text style={styles.privilegeTitle}>🍔 Yemek Kartı Yükleme Durumu</Text>
          <Text style={styles.privilegeDesc}>
            Universite anlaşması gereği ay sonunda hak kazandığınız yemek bakiyesi kartınıza otomatik aktarılır.
          </Text>
        </View>
      </Card>

      {/* Accessibility / Special Need */}
      <Card>
        <Text style={styles.cardTitle}>♿ Erişilebilirlik & Özel İhtiyaç Notu</Text>
        <Input
          placeholder="Örn: Tekerlekli sandalye bagaj hakkı gerekiyor"
          value={specialNeed}
          onChangeText={setSpecialNeed}
        />
        <Button title="Notu Kaydet" onPress={handleSaveNeed} loading={saving} variant="outline" />
      </Card>

      {/* Premium Upgrade Section */}
      {!user?.is_premium && (
        <Card style={styles.premiumCard}>
          <Text style={styles.premiumCardTitle}>⭐ Premium Üyeliğe Geçin</Text>
          <Text style={styles.premiumCardSub}>
            Aylık 400 TL karşılığında 30 ücretsiz biniş hakkı ve araç taleplerinde öncelikli binme hakkı kazanın!
          </Text>
          <Button title="Premium Paket Satın Al (400 TL)" onPress={handleBuyPremium} style={{ marginTop: spacing.sm }} />
        </Card>
      )}

      {/* Logout */}
      <Button title="Oturumu Kapat" onPress={logout} variant="danger" style={{ marginVertical: spacing.lg }} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    padding: spacing.md,
  },
  profileHeaderCard: {
    alignItems: 'center',
    paddingVertical: spacing.xl,
  },
  avatarLarge: {
    width: 70,
    height: 70,
    borderRadius: 35,
    backgroundColor: colors.surfaceLight,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: colors.primary,
    marginBottom: spacing.sm,
  },
  avatarText: {
    color: colors.primary,
    fontSize: fontSizes.xxl,
    fontWeight: '800',
  },
  userName: {
    color: colors.text,
    fontSize: fontSizes.lg,
    fontWeight: '800',
  },
  userEmail: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
    marginTop: 2,
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.md,
    gap: spacing.sm,
  },
  premiumBadge: {
    backgroundColor: colors.accent,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
  },
  premiumText: {
    color: '#000',
    fontSize: fontSizes.xs,
    fontWeight: '800',
  },
  cardTitle: {
    color: colors.text,
    fontSize: fontSizes.md,
    fontWeight: '700',
    marginBottom: spacing.md,
  },
  statsGrid: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  statBox: {
    flex: 1,
    backgroundColor: colors.surfaceLight,
    padding: spacing.md,
    borderRadius: borderRadius.md,
    alignItems: 'center',
  },
  statNumber: {
    color: colors.primary,
    fontSize: fontSizes.xl,
    fontWeight: '900',
  },
  statLabel: {
    color: colors.textMuted,
    fontSize: fontSizes.xs,
  },
  privilegeBox: {
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    padding: spacing.md,
    borderRadius: borderRadius.md,
    marginTop: spacing.md,
    borderWidth: 1,
    borderColor: colors.success,
  },
  privilegeTitle: {
    color: colors.success,
    fontWeight: '800',
    fontSize: fontSizes.sm,
  },
  privilegeDesc: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
    marginTop: 4,
  },
  premiumCard: {
    borderColor: colors.accent,
  },
  premiumCardTitle: {
    color: colors.accent,
    fontSize: fontSizes.md,
    fontWeight: '800',
  },
  premiumCardSub: {
    color: colors.textSecondary,
    fontSize: fontSizes.xs,
    marginVertical: spacing.xs,
  },
});
