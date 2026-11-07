import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, borderRadius, spacing, fontSizes } from '../theme/theme';

interface BadgeProps {
  level: 'baslangic' | 'guvenilir' | 'yildiz' | 'elit';
}

const badgeConfig = {
  baslangic: { title: '🥉 Başlangıç', color: colors.badge.baslangic },
  guvenilir: { title: '🥈 Güvenilir Sürücü', color: colors.badge.guvenilir },
  yildiz: { title: '🥇 Yıldız Sürücü', color: colors.badge.yildiz },
  elit: { title: '💎 Elit Sürücü', color: colors.badge.elit },
};

export const Badge: React.FC<BadgeProps> = ({ level }) => {
  const badge = badgeConfig[level] || badgeConfig.baslangic;

  return (
    <View style={[styles.container, { borderColor: badge.color }]}>
      <Text style={[styles.text, { color: badge.color }]}>{badge.title}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borderRadius.full,
    borderWidth: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.6)',
    alignSelf: 'flex-start',
  },
  text: {
    fontSize: fontSizes.xs,
    fontWeight: '700',
  },
});
